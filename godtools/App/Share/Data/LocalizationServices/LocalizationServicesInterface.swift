//
//  LocalizationServicesInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import LocalizationServices

protocol LocalizationServicesInterface: Sendable {
    
    func stringForEnglish(key: String) async -> String
    func stringForSystemElseEnglish(key: String) async -> String
    func stringForLocaleElseEnglish(localeIdentifier: String?, key: String) async -> String
    func stringForLocaleElseSystemElseEnglish(localeIdentifier: String?, key: String) async -> String
    func stringForFirstLocaleElseEnglish(localeIdentifiers: [String], key: String) async -> String
}

extension LocalizationServices: LocalizationServicesInterface {
    
    func stringForFirstLocaleElseEnglish(localeIdentifiers: [String], key: String) async -> String {
        
        for localeId in localeIdentifiers {
            if let string = await stringForLocale(localeIdentifier: localeId, key: key) {
                return string
            }
        }
        
        return await stringForEnglish(key: key)
    }
}
