//
//  String+Localized.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.11.2025.
//

import Foundation

extension String {
    /// Returns the localized string for the current key
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, comment: "")
    }
    
    /// Returns the localized string with format arguments
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}
