//
//  MockLocalizationServices.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import LocalizationServices

class MockLocalizationServices: LocalizationServicesInterface {
    
    typealias LocaleId = StringKey
    typealias StringKey = String
    
    private let localizableStrings: [LocaleId: [StringKey: String]]
    
    init(localizableStrings: [LocaleId: [StringKey: String]]) {
        
        self.localizableStrings = localizableStrings
    }
    
    func stringForEnglish(key: String) -> String {
        
        return stringForLocaleElseEnglish(localeIdentifier: "en", key: key)
    }
    
    func stringForSystemElseEnglish(key: String) -> String {
        
        return stringForLocaleElseEnglish(localeIdentifier: "en", key: key)
    }
    
    func stringForLocaleElseEnglish(localeIdentifier: String?, key: String) -> String {
        
        guard let localeIdentifier = localeIdentifier else {
            return ""
        }
        
        guard let localizedStrings = localizableStrings[localeIdentifier] else {
            return ""
        }
        
        return localizedStrings[key] ?? ""
    }
    
    func stringForLocaleElseSystemElseEnglish(localeIdentifier: String?, key: String) -> String {
        
        return stringForLocaleElseEnglish(localeIdentifier: localeIdentifier, key: key)
    }
}
