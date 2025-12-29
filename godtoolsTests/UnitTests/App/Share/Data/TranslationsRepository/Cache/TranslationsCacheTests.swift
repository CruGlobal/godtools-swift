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
import RealmSwift
import SwiftData

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
    func getRealmEnglishTranslation() async throws {
        
        let translationsCache = getTranslationsCache(swiftPersistenceIsEnabled: false)
        
        let translationId: String = "e0"
        
        let translation: TranslationDataModel = try #require(translationsCache.getPersistence().getObject(id: translationId))
        
        #expect(translation.id == translationId)
        #expect(translation.languageDataModel?.id == Self.englishLanguageId)
        #expect(translation.resourceDataModel?.id == Self.resourceId)
    }
    /*
    @Test()
    func getSwiftEnglishTranslation() async throws {
        
        let translationsCache = getTranslationsCache(swiftPersistenceIsEnabled: true)
        
        let translationId: String = "e0"
        
        let translation: TranslationDataModel = try #require(translationsCache.getPersistence().getObject(id: translationId))
        
        #expect(translation.id == translationId)
        #expect(translation.languageDataModel?.id == Self.englishLanguageId)
        #expect(translation.resourceDataModel?.id == Self.resourceId)
    }*/
    
    @Test(arguments: [
        TestArgument(expectedVersion: 12, languageId: englishLanguageId),
        TestArgument(expectedVersion: 122, languageId: spanishLanguageId),
        TestArgument(expectedVersion: 20, languageId: vietnameseLanguageId)
    ])
    func realmGetLatestTranslationByLanguageId(argument: TestArgument) async throws {
             
        let translationsCache = getTranslationsCache(swiftPersistenceIsEnabled: false)
        
        let languageId: String = try #require(argument.languageId)
        
        let translation = translationsCache.getLatestTranslation(
            resourceId: argument.resourceId,
            languageId: languageId
        )
                
        #expect(translation?.version == argument.expectedVersion)
    }
    /*
    @Test(arguments: [
        TestArgument(expectedVersion: 12, languageId: englishLanguageId),
        TestArgument(expectedVersion: 122, languageId: spanishLanguageId),
        TestArgument(expectedVersion: 20, languageId: vietnameseLanguageId)
    ])
    func getLatestTranslationByLanguageId(argument: TestArgument) async throws {
             
        let translationsCache = getTranslationsCache(swiftPersistenceIsEnabled: true)
        
        let languageId: String = try #require(argument.languageId)
        
        let translation = translationsCache.getLatestTranslation(
            resourceId: argument.resourceId,
            languageId: languageId
        )
                
        #expect(translation?.version == argument.expectedVersion)
    }*/
}

extension TranslationsCacheTests {
    
    private func getTranslationsCache(swiftPersistenceIsEnabled: Bool) -> TranslationsCache {
        
        if #available(iOS 17.4, *), swiftPersistenceIsEnabled {
            TempSharedSwiftDatabase.shared.setDatabase(
                swiftDatabase: getSwiftDatabase()
            )
        }
        
        return TranslationsCache(
            realmDatabase: getLegacyRealmDatabase(),
            swiftPersistenceIsEnabled: swiftPersistenceIsEnabled
        )
    }
}

// MARK: - RealmDatabase

extension TranslationsCacheTests {
    
    private func getEnglishLanguage() -> RealmLanguage {
        return MockRealmLanguage.createLanguage(language: .english, name: "english", id: Self.englishLanguageId)
    }
    
    private func getSpanishLanguage() -> RealmLanguage {
        return MockRealmLanguage.createLanguage(language: .spanish, name: "spanish", id: Self.spanishLanguageId)
    }
    
    private func getVietnameseLanguage() -> RealmLanguage {
        return MockRealmLanguage.createLanguage(language: .vietnamese, name: "vietnamese", id: Self.vietnameseLanguageId)
    }
    
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
    
    private func getRealmDatabaseObjects() -> [Object] {
        
        let english: RealmLanguage = getEnglishLanguage()
        let spanish: RealmLanguage = getSpanishLanguage()
        let vietnamese: RealmLanguage = getVietnameseLanguage()
        
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
        
        return [resource]
    }
    
    private func getLegacyRealmDatabase() -> LegacyRealmDatabase {
        return TestsInMemoryRealmDatabase(
            addObjectsToDatabase: getRealmDatabaseObjects()
        )
    }
}

// MARK: - SwiftDatabase

extension TranslationsCacheTests {
    
    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any IdentifiableSwiftDataObject] {
        
        let english = SwiftLanguage.createNewFrom(interface: getEnglishLanguage())
        let spanish = SwiftLanguage.createNewFrom(interface: getSpanishLanguage())
        let vietnamese = SwiftLanguage.createNewFrom(interface: getVietnameseLanguage())
        
        let resource = SwiftResource()
        resource.id = Self.resourceId
        //resource.languages = [english, spanish, vietnamese]
        
        let realmEnglishTranslations: [RealmTranslation] = getEnglishTranslations()
        let realmSpanishTranslations: [RealmTranslation] = getSpanishTranslations()
        let realmVietnameseTranslations: [RealmTranslation] = getVietnameseTranslations()
                        
        for translation in realmEnglishTranslations {
            
            let swiftTranslation = SwiftTranslation.createNewFrom(interface: translation)
            
            swiftTranslation.language = english
            swiftTranslation.resource = resource
            
            resource.latestTranslations.append(swiftTranslation)
        }
        
        for translation in realmSpanishTranslations {
            
            let swiftTranslation = SwiftTranslation.createNewFrom(interface: translation)
            
            swiftTranslation.language = spanish
            swiftTranslation.resource = resource
            
            resource.latestTranslations.append(swiftTranslation)
        }
        
        for translation in realmVietnameseTranslations {
            
            let swiftTranslation = SwiftTranslation.createNewFrom(interface: translation)
            
            swiftTranslation.language = vietnamese
            swiftTranslation.resource = resource
            
            resource.latestTranslations.append(swiftTranslation)
        }
                
        return [resource]
    }
    
    @available(iOS 17.4, *)
    private func getSwiftDatabase() -> SwiftDatabase {
        return TestsInMemorySwiftDatabase(
            addObjectsToDatabase: getSwiftDatabaseObjects()
        )
    }
}
