//
//  LocalizationHelper.swift
//  Night Prayers
//
//  Created for localization support
//

import Foundation
import SwiftUI

extension String {
    /// Localized string using the app's current language setting
    /// This works with SwiftUI's String(localized:) and the Localizable.xcstrings file
    var localized: String {
        // Use SwiftUI's built-in localization which respects the environment locale
        return String(localized: String.LocalizationValue(self))
    }
    
    /// Localized string with arguments
    func localized(_ arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}

