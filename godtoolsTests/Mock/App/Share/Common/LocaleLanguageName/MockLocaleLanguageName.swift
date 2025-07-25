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
    
    static func defaultMockLocaleLanguageName() -> MockLocaleLanguageName {
        
        let languageNames: [MockLocaleLanguageName.LanguageCode: [MockLocaleLanguageName.TranslateInLocaleId: MockLocaleLanguageName.LanguageName]] = [
            LanguageCodeDomainModel.afrikaans.rawValue: [
                LanguageCodeDomainModel.afrikaans.rawValue: "Afrikaans",
                LanguageCodeDomainModel.english.rawValue: "Afrikaans"
            ],
            LanguageCodeDomainModel.czech.rawValue: [
                LanguageCodeDomainModel.czech.rawValue: "čeština",
                LanguageCodeDomainModel.english.rawValue: "Czech"
            ],
            LanguageCodeDomainModel.english.rawValue: [
                LanguageCodeDomainModel.czech.rawValue: "Angličtina",
                LanguageCodeDomainModel.english.rawValue: "English",
                LanguageCodeDomainModel.french.rawValue: "Anglais",
                LanguageCodeDomainModel.portuguese.rawValue: "Inglês",
                LanguageCodeDomainModel.russian.rawValue: "Английский",
                LanguageCodeDomainModel.spanish.rawValue: "Inglés"
            ],
            LanguageCodeDomainModel.french.rawValue: [
                LanguageCodeDomainModel.czech.rawValue: "francouzština",
                LanguageCodeDomainModel.english.rawValue: "French",
                LanguageCodeDomainModel.french.rawValue: "Français",
                LanguageCodeDomainModel.portuguese.rawValue: "Francês",
                LanguageCodeDomainModel.russian.rawValue: "Французский",
                LanguageCodeDomainModel.spanish.rawValue: "Francés"
            ],
            LanguageCodeDomainModel.spanish.rawValue: [
                LanguageCodeDomainModel.czech.rawValue: "španělština",
                LanguageCodeDomainModel.english.rawValue: "Spanish",
                LanguageCodeDomainModel.french.rawValue: "Espagnol",
                LanguageCodeDomainModel.portuguese.rawValue: "Espanhol",
                LanguageCodeDomainModel.russian.rawValue: "испанский",
                LanguageCodeDomainModel.spanish.rawValue: "Español"
            ]
        ]
        
        return MockLocaleLanguageName(languageNames: languageNames)
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
