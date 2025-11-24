//
//  TranslationsCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 11/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation

struct TranslationsCacheTests {
    
    private static let resourceId: String = "0"
    private static let englishLanguageId: String = "0"
    private static let spanishLanguageId: String = "1"
    private static let vietnameseLanguageId: String = "2"
    
    struct TestArgument {
        
        let resourceId: String
        let languageId: String?
        let expectedVersion: Int
        
        init(expectedVersion: Int, languageId: String? = nil, resourceId: String = TranslationsCacheTests.resourceId) {
            
            self.resourceId = resourceId
            self.languageId = languageId
            self.expectedVersion = expectedVersion
        }
    }
    
    @Test()
    func getEnglishTranslation() async throws {
        
        let translationsCache = getTranslationsCache()
        
        let translationId: String = "e0"
        
        let translation: TranslationDataModel = try #require(translationsCache.getPersistence().getObject(id: translationId))
        
        #expect(translation.id == translationId)
        #expect(translation.languageDataModel?.id == Self.englishLanguageId)
        #expect(translation.resourceDataModel?.id == Self.resourceId)
    }
    
    @Test(arguments: [
        TestArgument(expectedVersion: 12, languageId: englishLanguageId),
        TestArgument(expectedVersion: 122, languageId: spanishLanguageId),
        TestArgument(expectedVersion: 20, languageId: vietnameseLanguageId)
    ])
    func getLatestTranslationByLanguageId(argument: TestArgument) async throws {
             
        let translationsCache = getTranslationsCache()
        
        let languageId: String = try #require(argument.languageId)
        
        let translation = translationsCache.getLatestTranslation(
            resourceId: argument.resourceId,
            languageId: languageId
        )
                
        #expect(translation?.version == argument.expectedVersion)
    }
}

extension TranslationsCacheTests {
    
    private func getEnglishTranslations() -> [RealmTranslation] {
        return [
            MockRealmTranslation.createTranslation(translatedName: "english-0", id: "e0", version: 0),
            MockRealmTranslation.createTranslation(translatedName: "english-1", id: "e1", version: 1),
            MockRealmTranslation.createTranslation(translatedName: "english-5", id: "e5", version: 5),
            MockRealmTranslation.createTranslation(translatedName: "english-12", id: "e12", version: 12)
        ]
    }
    
    private func getSpanishTranslations() -> [RealmTranslation] {
        return [
            MockRealmTranslation.createTranslation(translatedName: "spanish-5", id: "s5", version: 5),
            MockRealmTranslation.createTranslation(translatedName: "spanish-12", id: "s12", version: 12),
            MockRealmTranslation.createTranslation(translatedName: "spanish-25", id: "s25", version: 25),
            MockRealmTranslation.createTranslation(translatedName: "spanish-122", id: "s122", version: 122)
        ]
    }
    
    private func getVietnameseTranslations() -> [RealmTranslation] {
        return [
            MockRealmTranslation.createTranslation(translatedName: "vietnamese-0", id: "v0", version: 0),
            MockRealmTranslation.createTranslation(translatedName: "vietnamese-12", id: "v12", version: 12),
            MockRealmTranslation.createTranslation(translatedName: "vietnamese-15", id: "v15", version: 15),
            MockRealmTranslation.createTranslation(translatedName: "vietnamese-20", id: "v20", version: 20)
        ]
    }
    
    private func getTranslationsCache() -> TranslationsCache {
        
        let english: RealmLanguage = MockRealmLanguage.createLanguage(language: .english, name: "english", id: Self.englishLanguageId)
        let spanish: RealmLanguage = MockRealmLanguage.createLanguage(language: .spanish, name: "spanish", id: Self.spanishLanguageId)
        let vietnamese: RealmLanguage = MockRealmLanguage.createLanguage(language: .vietnamese, name: "vietnamese", id: Self.vietnameseLanguageId)
        
        let resource: RealmResource = MockRealmResource.createTract(
            addLanguages: [.english, .spanish, .vietnamese],
            fromLanguages: [english, spanish, vietnamese],
            id: Self.resourceId
        )
        
        let englishTranslations: [RealmTranslation] = getEnglishTranslations()
        let spanishTranslations: [RealmTranslation] = getSpanishTranslations()
        let vietnameseTranslations: [RealmTranslation] = getVietnameseTranslations()
        
        for translation in englishTranslations {
            translation.language = english
            translation.resource = resource
            resource.addLatestTranslation(translation: translation)
        }
        
        for translation in spanishTranslations {
            translation.language = spanish
            translation.resource = resource
            resource.addLatestTranslation(translation: translation)
        }
        
        for translation in vietnameseTranslations {
            translation.language = vietnamese
            translation.resource = resource
            resource.addLatestTranslation(translation: translation)
        }
        
        let realmDatabase = TestsInMemoryRealmDatabase(
            addObjectsToDatabase: [resource]
        )
        
        return TranslationsCache(realmDatabase: realmDatabase)
    }
}
