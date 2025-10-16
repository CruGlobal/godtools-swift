//
//  LocalizationServicesInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import LocalizationServices

protocol LocalizationServicesInterface {
    
    func stringForEnglish(key: String) -> String
    func stringForSystemElseEnglish(key: String) -> String
    func stringForLocaleElseEnglish(localeIdentifier: String?, key: String) -> String
    func stringForLocaleElseSystemElseEnglish(localeIdentifier: String?, key: String) -> String
    func stringForFirstLocaleElseEnglish(localeIdentifiers: [String], key: String) -> String
}

extension LocalizationServices: LocalizationServicesInterface {
    
    func stringForFirstLocaleElseEnglish(localeIdentifiers: [String], key: String) -> String {
        
        for localeId in localeIdentifiers {
            if let string = stringForLocale(localeIdentifier: localeId, key: key) {
                return string
            }
        }
        
        return stringForEnglish(key: key)
    }
}
