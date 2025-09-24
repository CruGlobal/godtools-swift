//
//  LanguagesRepositoryTests.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation

struct LanguagesRepositoryTests {
        
    @Test()
    @MainActor func returnsLanguageByCode() async {
        
        let languagesRepository: LanguagesRepository = getLanguagesRepository()
        
        let language: LanguageDataModel? = languagesRepository.cache.getCachedLanguage(code: LanguageCodeDomainModel.arabic.rawValue)
        
        #expect(language?.code == LanguageCodeDomainModel.arabic.rawValue)
    }
    
    @Test()
    @MainActor func returnsLanguagesByCodes() async {
        
        let languagesRepository: LanguagesRepository = getLanguagesRepository()
        
        let languages: [LanguageDataModel] = languagesRepository.getCachedLanguages(
            languageCodes: [
                LanguageCodeDomainModel.arabic.rawValue,
                LanguageCodeDomainModel.czech.rawValue,
                LanguageCodeDomainModel.english.rawValue,
                LanguageCodeDomainModel.latvian.rawValue
            ]
        )
        
        #expect(languages[0].code == LanguageCodeDomainModel.arabic.rawValue)
        #expect(languages[1].code == LanguageCodeDomainModel.czech.rawValue)
        #expect(languages[2].code == LanguageCodeDomainModel.english.rawValue)
        #expect(languages[3].code == LanguageCodeDomainModel.latvian.rawValue)
    }
}

extension LanguagesRepositoryTests {
    
    private func getLanguagesRepository() -> LanguagesRepository {
        
        let languages: [RealmLanguage] = [
            MockRealmLanguage.getLanguage(language: .afrikaans, name: "afrikaans", id: "0"),
            MockRealmLanguage.getLanguage(language: .arabic, name: "arabic", id: "1"),
            MockRealmLanguage.getLanguage(language: .chinese, name: "chinese", id: "2"),
            MockRealmLanguage.getLanguage(language: .czech, name: "czech", id: "3"),
            MockRealmLanguage.getLanguage(language: .english, name: "english", id: "4"),
            MockRealmLanguage.getLanguage(language: .french, name: "french", id: "5"),
            MockRealmLanguage.getLanguage(language: .hebrew, name: "hebrew", id: "6"),
            MockRealmLanguage.getLanguage(language: .latvian, name: "latvian", id: "7"),
            MockRealmLanguage.getLanguage(language: .portuguese, name: "portuguese", id: "8"),
            MockRealmLanguage.getLanguage(language: .russian, name: "russian", id: "9")
        ]
        
        let realmDatabase = TestsInMemoryRealmDatabase(addObjectsToDatabase: languages)
        
        let testsDiContainer = TestsDiContainer(realmDatabase: realmDatabase)
        
        return testsDiContainer.dataLayer.getLanguagesRepository()
    }
}
