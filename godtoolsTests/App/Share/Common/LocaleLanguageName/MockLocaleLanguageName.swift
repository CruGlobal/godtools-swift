//
//  MockLocaleLanguageName.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockLocaleLanguageName: LocaleLanguageNameInterface {
    
    typealias LanguageCode = String
    typealias TranslateInLocaleId = String
    typealias LanguageName = String
    
    private let languageNames: [LanguageCode: [TranslateInLocaleId: LanguageName]]
    
    init(languageNames: [LanguageCode: [TranslateInLocaleId: LanguageName]]) {
        
        self.languageNames = languageNames
    }

    func getLanguageName(forLanguageCode: String, translatedInLanguageId: BCP47LanguageIdentifier?) -> String? {
        
        if let translatedInLanguageId = translatedInLanguageId {
            
            return languageNames[forLanguageCode]?[translatedInLanguageId]
        }
        
        return languageNames[forLanguageCode]?[forLanguageCode]
    }
    
    func getLanguageName(forLocaleId: String, translatedInLanguageId: BCP47LanguageIdentifier?) -> String? {
        
        return getLanguageName(forLanguageCode: forLocaleId, translatedInLanguageId: translatedInLanguageId)
    }
}
