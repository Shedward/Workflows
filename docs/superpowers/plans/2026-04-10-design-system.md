# Design System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a minimal, token-based design system for WorkflowApp with colors, fonts, spacing, and view modifiers — all backed by macOS system colors.

**Architecture:** Token structs (`Colors`, `Fonts`, `Spacing`) bundled in a `Theme` value type, injected via SwiftUI `EnvironmentValues`. View modifiers read the environment internally so consumers never write `@Environment(\.theme)` for static styling.

**Tech Stack:** Swift, SwiftUI, macOS 26

**Spec:** `docs/superpowers/specs/2026-04-10-design-system.md`

**Build command:** `./Tools/Run/build`

---

## File Structure

All files inside `Apps/WorkflowApp/Sources/WorkflowApp/DesignSystem/`:

| File | Responsibility |
|---|---|
| `Colors.swift` | `ColorSet` and `Colors` structs |
| `Fonts.swift` | `Fonts` struct |
| `Spacing.swift` | `Spacing` struct |
| `Theme.swift` | `Theme` struct, `.system` factory, `EnvironmentKey`, `.theme()` modifier |
| `Modifiers/ThemeColorModifier.swift` | `.themeColor()` and `.themeBackground()` view modifiers |
| `Modifiers/ThemeFontModifier.swift` | `.themeFont()` view modifier |
| `Modifiers/ThemePaddingModifier.swift` | `.themePadding()` view modifier |

---

### Task 1: Colors

**Files:**
- Create: `Apps/WorkflowApp/Sources/WorkflowApp/DesignSystem/Colors.swift`

- [ ] **Step 1: Create `ColorSet` and `Colors` structs**

```swift
//
//  Colors.swift
//  WorkflowApp
//

import SwiftUI

struct ColorSet {
    let primary: Color
    let secondary: Color
    let tertiary: Color
}

struct Colors {
    let content: ColorSet
    let background: ColorSet
    let accent: Color
    let positive: Color
    let negative: Color
    let warning: Color
}
```

- [ ] **Step 2: Add system color factory**

Add a static property to `Colors`:

```swift
extension Colors {
    static let system = Colors(
        content: ColorSet(
            primary: Color(.labelColor),
            secondary: Color(.secondaryLabelColor),
            tertiary: Color(.tertiaryLabelColor)
        ),
        background: ColorSet(
            primary: Color(.textBackgroundColor),
            secondary: Color(.controlBackgroundColor),
            tertiary: Color(.windowBackgroundColor)
        ),
        accent: Color(.controlAccentColor),
        positive: Color(.systemGreen),
        negative: Color(.systemRed),
        warning: Color(.systemOrange)
    )
}
```

- [ ] **Step 3: Verify it compiles**

Run: `./Tools/Run/build`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add Apps/WorkflowApp/Sources/WorkflowApp/DesignSystem/Colors.swift
git commit -m "Add Colors and ColorSet structs with system color mapping"
```

---

### Task 2: Fonts

**Files:**
- Create: `Apps/WorkflowApp/Sources/WorkflowApp/DesignSystem/Fonts.swift`

- [ ] **Step 1: Create `Fonts` struct with system factory**

```swift
//
//  Fonts.swift
//  WorkflowApp
//

import SwiftUI

struct Fonts {
    let title: Font
    let subtitle: Font
    let body: Font
    let caption: Font
    let mono: Font
}

extension Fonts {
    static let system = Fonts(
        title: .headline,
        subtitle: .subheadline,
        body: .body,
        caption: .caption,
        mono: .body.monospaced()
    )
}
```

- [ ] **Step 2: Verify it compiles**

Run: `./Tools/Run/build`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add Apps/WorkflowApp/Sources/WorkflowApp/DesignSystem/Fonts.swift
git commit -m "Add Fonts struct with system font mapping"
```

---

### Task 3: Spacing

**Files:**
- Create: `Apps/WorkflowApp/Sources/WorkflowApp/DesignSystem/Spacing.swift`

- [ ] **Step 1: Create `Spacing` struct**

```swift
//
//  Spacing.swift
//  WorkflowApp
//

import SwiftUI

struct Spacing {
    let xxs: CGFloat
    let xs: CGFloat
    let s: CGFloat
    let m: CGFloat
    let l: CGFloat
    let xl: CGFloat
    let cornerRadius: CGFloat
}

extension Spacing {
    static let `default` = Spacing(
        xxs: 2,
        xs: 4,
        s: 6,
        m: 8,
        l: 12,
        xl: 16,
        cornerRadius: 8
    )
}
```

- [ ] **Step 2: Verify it compiles**

Run: `./Tools/Run/build`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add Apps/WorkflowApp/Sources/WorkflowApp/DesignSystem/Spacing.swift
git commit -m "Add Spacing struct with default compact scale"
```

---

### Task 4: Theme and Environment

**Files:**
- Create: `Apps/WorkflowApp/Sources/WorkflowApp/DesignSystem/Theme.swift`

- [ ] **Step 1: Create `Theme` struct with system factory**

```swift
//
//  Theme.swift
//  WorkflowApp
//

import SwiftUI

struct Theme {
    let colors: Colors
    let fonts: Fonts
    let spacing: Spacing
}

extension Theme {
    static let system = Theme(
        colors: .system,
        fonts: .system,
        spacing: .default
    )
}
```

- [ ] **Step 2: Add EnvironmentKey and View extension**

Add to the same file, below the `Theme` struct:

```swift
private struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue = Theme.system
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

extension View {
    func theme(_ theme: Theme) -> some View {
        environment(\.theme, theme)
    }
}
```

- [ ] **Step 3: Verify it compiles**

Run: `./Tools/Run/build`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add Apps/WorkflowApp/Sources/WorkflowApp/DesignSystem/Theme.swift
git commit -m "Add Theme struct with environment injection"
```

---

### Task 5: Color Modifiers

**Files:**
- Create: `Apps/WorkflowApp/Sources/WorkflowApp/DesignSystem/Modifiers/ThemeColorModifier.swift`

- [ ] **Step 1: Create foreground color modifier**

```swift
//
//  ThemeColorModifier.swift
//  WorkflowApp
//

import SwiftUI

private struct ThemeForegroundColorModifier: ViewModifier {
    @Environment(\.theme) private var theme
    let keyPath: KeyPath<Colors, Color>

    func body(content: Content) -> some View {
        content.foregroundStyle(theme.colors[keyPath: keyPath])
    }
}

extension View {
    func themeColor(_ keyPath: KeyPath<Colors, Color>) -> some View {
        modifier(ThemeForegroundColorModifier(keyPath: keyPath))
    }
}
```

- [ ] **Step 2: Add background color modifier**

Add to the same file:

```swift
private struct ThemeBackgroundColorModifier: ViewModifier {
    @Environment(\.theme) private var theme
    let keyPath: KeyPath<Colors, Color>

    func body(content: Content) -> some View {
        content.background(theme.colors[keyPath: keyPath])
    }
}

extension View {
    func themeBackground(_ keyPath: KeyPath<Colors, Color>) -> some View {
        modifier(ThemeBackgroundColorModifier(keyPath: keyPath))
    }
}
```

- [ ] **Step 3: Verify it compiles**

Run: `./Tools/Run/build`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add Apps/WorkflowApp/Sources/WorkflowApp/DesignSystem/Modifiers/ThemeColorModifier.swift
git commit -m "Add themeColor and themeBackground view modifiers"
```

---

### Task 6: Font Modifier

**Files:**
- Create: `Apps/WorkflowApp/Sources/WorkflowApp/DesignSystem/Modifiers/ThemeFontModifier.swift`

- [ ] **Step 1: Create font modifier**

```swift
//
//  ThemeFontModifier.swift
//  WorkflowApp
//

import SwiftUI

private struct ThemeFontModifier: ViewModifier {
    @Environment(\.theme) private var theme
    let keyPath: KeyPath<Fonts, Font>

    func body(content: Content) -> some View {
        content.font(theme.fonts[keyPath: keyPath])
    }
}

extension View {
    func themeFont(_ keyPath: KeyPath<Fonts, Font>) -> some View {
        modifier(ThemeFontModifier(keyPath: keyPath))
    }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `./Tools/Run/build`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add Apps/WorkflowApp/Sources/WorkflowApp/DesignSystem/Modifiers/ThemeFontModifier.swift
git commit -m "Add themeFont view modifier"
```

---

### Task 7: Padding Modifier

**Files:**
- Create: `Apps/WorkflowApp/Sources/WorkflowApp/DesignSystem/Modifiers/ThemePaddingModifier.swift`

- [ ] **Step 1: Create padding modifier**

```swift
//
//  ThemePaddingModifier.swift
//  WorkflowApp
//

import SwiftUI

private struct ThemePaddingModifier: ViewModifier {
    @Environment(\.theme) private var theme
    let keyPath: KeyPath<Spacing, CGFloat>
    let edges: Edge.Set

    func body(content: Content) -> some View {
        content.padding(edges, theme.spacing[keyPath: keyPath])
    }
}

extension View {
    func themePadding(_ keyPath: KeyPath<Spacing, CGFloat>, _ edges: Edge.Set = .all) -> some View {
        modifier(ThemePaddingModifier(keyPath: keyPath, edges: edges))
    }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `./Tools/Run/build`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add Apps/WorkflowApp/Sources/WorkflowApp/DesignSystem/Modifiers/ThemePaddingModifier.swift
git commit -m "Add themePadding view modifier"
```

---

### Task 8: Wire Theme into App and Verify

**Files:**
- Modify: `Apps/WorkflowApp/Sources/WorkflowApp/UI/Focus/Focus.swift`

- [ ] **Step 1: Update Focus view to use theme modifiers**

Replace the current `Focus` view body with themed styling as a smoke test that the full system works end-to-end:

```swift
struct Focus: View {
    @State
    private var isExpanded: Bool = false

    var body: some View {
        VStack {
            Text("Focus")
                .themeFont(\.title)
                .themeColor(\.content.primary)
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                Text("Button")
                    .themeFont(\.body)
            }

            if isExpanded {
                Rectangle()
                    .fill(.primary)
                    .frame(width: 100, height: 100)
            }
        }
        .themePadding(\.m)
        .background(.regularMaterial, in: .rect(corners: .concentric(minimum: 8)))
        .shadow(radius: 12)
    }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `./Tools/Run/build`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add Apps/WorkflowApp/Sources/WorkflowApp/UI/Focus/Focus.swift
git commit -m "Wire theme modifiers into Focus view as smoke test"
```
