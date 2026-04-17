//
//  GlobalHotkey.swift
//  WorkflowApp
//
//  Created by Vlad Maltsev on 09.04.2026.
//

import AppKit
import Carbon.HIToolbox

/// Registers a system-wide hotkey via Carbon's `RegisterEventHotKey`.
///
/// Carbon hotkeys do not require Accessibility permissions and intercept the
/// chord before it reaches any other app. The Carbon event handler runs on the
/// main thread, so all state is `@MainActor`-isolated.
@MainActor
final class GlobalHotkey {
    private static var nextID: UInt32 = 1
    private static var handlers: [UInt32: () -> Void] = [:]
    private static var eventHandler: EventHandlerRef?

    private static func installEventHandlerIfNeeded() {
        guard eventHandler == nil else {
            return
        }

        var spec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, _ -> OSStatus in
                guard let event else {
                    return OSStatus(eventNotHandledErr)
                }
                var hotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                guard status == noErr else {
                    return status
                }
                MainActor.assumeIsolated {
                    GlobalHotkey.handlers[hotKeyID.id]?()
                }
                return noErr
            },
            1,
            &spec,
            nil,
            &eventHandler
        )
    }

    private let id: UInt32
    private var hotKeyRef: EventHotKeyRef?

    init(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) {
        Self.installEventHandlerIfNeeded()

        let id = Self.nextID
        Self.nextID += 1
        self.id = id
        Self.handlers[id] = handler

        let signature: OSType = 0x57464C57 // 'WFLW'
        let hotKeyID = EventHotKeyID(signature: signature, id: id)

        var ref: EventHotKeyRef?
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &ref
        )
        if status == noErr {
            self.hotKeyRef = ref
        } else {
            Self.handlers[id] = nil
        }
    }

    isolated deinit {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
        }
        Self.handlers[id] = nil
    }
}
