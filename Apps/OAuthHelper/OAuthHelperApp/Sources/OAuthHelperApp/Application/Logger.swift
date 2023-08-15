//
//  Logger.swift
//
//
//  Created by v.maltsev on 15.08.2023.
//

import Prelude
import os

extension Logger {
    init(scope: LoggerScope) {
        self.init(subsystem: "OAuthHelperApp", scope: scope)
    }
}
