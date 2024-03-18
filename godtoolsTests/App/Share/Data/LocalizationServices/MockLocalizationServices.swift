//
//  MockLocalizationServices.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockLocalizationServices: LocalizationServicesInterface {
    
    typealias LocaleId = StringKey
    typealias StringKey = String
    
    private let localizableStrings: [LocaleId: [StringKey: String]]
    
    init(localizableStrings: [LocaleId: [StringKey: String]]) {
        
        self.localizableStrings = localizableStrings
    }
    
    func stringForEnglish(key: String, fileType: LocalizableStringsFileType) -> String {
        
        return stringForLocaleElseEnglish(localeIdentifier: "en", key: key, fileType: fileType)
    }
    
    func stringForSystemElseEnglish(key: String, fileType: LocalizableStringsFileType) -> String {
        
        return stringForLocaleElseEnglish(localeIdentifier: "en", key: key, fileType: fileType)
    }
    
    func stringForLocaleElseEnglish(localeIdentifier: String?, key: String, fileType: LocalizableStringsFileType) -> String {
        
        guard let localeIdentifier = localeIdentifier else {
            return ""
        }
        
        guard let localizedStrings = localizableStrings[localeIdentifier] else {
            return ""
        }
        
        return localizedStrings[key] ?? ""
    }
    
    func stringForLocaleElseSystemElseEnglish(localeIdentifier: String?, key: String, fileType: LocalizableStringsFileType) -> String {
        
        return stringForLocaleElseEnglish(localeIdentifier: localeIdentifier, key: key, fileType: fileType)
    }
}
