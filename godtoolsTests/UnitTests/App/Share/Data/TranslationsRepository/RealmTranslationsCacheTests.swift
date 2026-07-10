//
//  RealmTranslationsCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 11/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import RealmSwift
import RepositorySync

struct RealmTranslationsCacheTests {
    
    private static let resourceId: String = "0"
    private static let englishLanguageId: String = "0"
    private static let spanishLanguageId: String = "1"
    private static let vietnameseLanguageId: String = "2"
    
    struct TestArgument {
        
        let resourceId: String
        let languageId: String?
        let expectedVersion: Int
        
        init(expectedVersion: Int, languageId: String? = nil, resourceId: String = RealmTranslationsCacheTests.resourceId) {
            
            self.resourceId = resourceId
            self.languageId = languageId
            self.expectedVersion = expectedVersion
        }
    }
    
    @Test()
    func getEnglishTranslation() async throws {
        
        let translationsCache = try getCache()
        
        let translationId: String = "e0"
        
        let translation: TranslationDataModel = try #require(try translationsCache.persistence.getDataModel(id: translationId))
        
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
             
        let translationsCache = try getCache()
        
        let languageId: String = try #require(argument.languageId)
        
        let translation = try translationsCache.getLatestTranslation(
            resourceId: argument.resourceId,
            languageId: languageId
        )
                
        #expect(translation?.version == argument.expectedVersion)
    }
}

extension RealmTranslationsCacheTests {
    
    private func getCache() throws -> TranslationsCache {
        
        let testsDiContainer = try TestsDiContainer(addRealmObjects: getRealmDatabaseObjects())
                
        let persistence = RealmRepositorySyncPersistence(
            database: testsDiContainer.core.dataLayer.getSharedRealmDatabase(),
            mapping: RealmTranslationMapping()
        )
                
        return TranslationsCache(
            persistence: persistence
        )
    }
    
    private func getLanguage(id: String, languageCode: LanguageCodeDomainModel, name: String) -> LanguageDataModel {

        let language = LanguageCodable.random(
            id: id,
            code: languageCode.rawValue,
            name: name,
            forceLanguageName: false
        )

        return language.toModel()
    }

    private func getEnglishLanguage() -> LanguageDataModel {
        return getLanguage(id: Self.englishLanguageId, languageCode: .english, name: "english")
    }

    private func getSpanishLanguage() -> LanguageDataModel {
        return getLanguage(id: Self.spanishLanguageId, languageCode: .spanish, name: "spanish")
    }

    private func getVietnameseLanguage() -> LanguageDataModel {
        return getLanguage(id: Self.vietnameseLanguageId, languageCode: .vietnamese, name: "vietnamese")
    }
    
    private func getTranslation(id: String, translatedName: String, version: Int) -> TranslationDataModel {

        let translation = TranslationCodable.random(id: id, translatedName: translatedName, version: version)

        return translation.toModel()
    }

    private func getEnglishTranslations() -> [TranslationDataModel] {
        return [
            getTranslation(id: "e0", translatedName: "english-0", version: 0),
            getTranslation(id: "e1", translatedName: "english-1", version: 1),
            getTranslation(id: "e5", translatedName: "english-5", version: 5),
            getTranslation(id: "e12", translatedName: "english-12", version: 12)
        ]
    }

    private func getSpanishTranslations() -> [TranslationDataModel] {
        return [
            getTranslation(id: "s5", translatedName: "spanish-5", version: 5),
            getTranslation(id: "s12", translatedName: "spanish-12", version: 12),
            getTranslation(id: "s25", translatedName: "spanish-25", version: 25),
            getTranslation(id: "s122", translatedName: "spanish-122", version: 122)
        ]
    }

    private func getVietnameseTranslations() -> [TranslationDataModel] {
        return [
            getTranslation(id: "v0", translatedName: "vietnamese-0", version: 0),
            getTranslation(id: "v12", translatedName: "vietnamese-12", version: 12),
            getTranslation(id: "v15", translatedName: "vietnamese-15", version: 15),
            getTranslation(id: "v20", translatedName: "vietnamese-20", version: 20)
        ]
    }
    
    private func getRealmDatabaseObjects() -> [IdentifiableRealmObject] {
        
        let english = RealmLanguage.createNewFrom(model: getEnglishLanguage())
        let spanish = RealmLanguage.createNewFrom(model: getSpanishLanguage())
        let vietnamese = RealmLanguage.createNewFrom(model: getVietnameseLanguage())
        
        let resource: RealmResource = FakeRealmResource.createTract(
            addLanguages: [.english, .spanish, .vietnamese],
            fromLanguages: [english, spanish, vietnamese],
            id: Self.resourceId
        )
        
        let englishTranslations: [TranslationDataModel] = getEnglishTranslations()
        let spanishTranslations: [TranslationDataModel] = getSpanishTranslations()
        let vietnameseTranslations: [TranslationDataModel] = getVietnameseTranslations()

        for translationModel in englishTranslations {
            let translation = RealmTranslation.createNewFrom(model: translationModel)
            translation.language = english
            translation.resource = resource
            resource.addLatestTranslation(translation: translation)
        }

        for translationModel in spanishTranslations {
            let translation = RealmTranslation.createNewFrom(model: translationModel)
            translation.language = spanish
            translation.resource = resource
            resource.addLatestTranslation(translation: translation)
        }

        for translationModel in vietnameseTranslations {
            let translation = RealmTranslation.createNewFrom(model: translationModel)
            translation.language = vietnamese
            translation.resource = resource
            resource.addLatestTranslation(translation: translation)
        }
        
        return [resource]
    }
}
