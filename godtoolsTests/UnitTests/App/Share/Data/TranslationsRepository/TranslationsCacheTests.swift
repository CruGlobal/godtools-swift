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
import SwiftData
import RepositorySync

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

    struct LanguageCodeArgument {

        let resourceId: String
        let languageCode: BCP47LanguageIdentifier
        let expectedVersion: Int

        init(expectedVersion: Int, languageCode: BCP47LanguageIdentifier, resourceId: String = TranslationsCacheTests.resourceId) {

            self.resourceId = resourceId
            self.languageCode = languageCode
            self.expectedVersion = expectedVersion
        }
    }

    struct MissingTranslationArgument {

        let resourceId: String
        let languageId: String

        init(languageId: String, resourceId: String = TranslationsCacheTests.resourceId) {

            self.resourceId = resourceId
            self.languageId = languageId
        }
    }

    @available(iOS 17.4, *)
    @Test
    func getEnglishTranslation() throws {

        let translationsCache = try getCache()

        let translationId: String = "e0"

        let translation: TranslationDataModel = try #require(try translationsCache.persistence.getDataModel(id: translationId))

        #expect(translation.id == translationId)
        #expect(translation.languageDataModel?.id == Self.englishLanguageId)
        #expect(translation.resourceDataModel?.id == Self.resourceId)
    }

    @available(iOS 17.4, *)
    @Test(arguments: [
        TestArgument(expectedVersion: 12, languageId: englishLanguageId),
        TestArgument(expectedVersion: 122, languageId: spanishLanguageId),
        TestArgument(expectedVersion: 20, languageId: vietnameseLanguageId)
    ])
    func getLatestTranslationByLanguageId(argument: TestArgument) throws {

        let translationsCache = try getCache()

        let languageId: String = try #require(argument.languageId)

        let translation = try translationsCache.getLatestTranslation(
            resourceId: argument.resourceId,
            languageId: languageId
        )

        #expect(translation?.version == argument.expectedVersion)
    }

    @available(iOS 17.4, *)
    @Test(arguments: [
        LanguageCodeArgument(expectedVersion: 12, languageCode: LanguageCodeDomainModel.english.rawValue),
        LanguageCodeArgument(expectedVersion: 122, languageCode: LanguageCodeDomainModel.spanish.rawValue),
        LanguageCodeArgument(expectedVersion: 20, languageCode: LanguageCodeDomainModel.vietnamese.rawValue)
    ])
    func getLatestTranslationByLanguageCode(argument: LanguageCodeArgument) throws {

        let translationsCache = try getCache()

        let translation = try translationsCache.getLatestTranslation(
            resourceId: argument.resourceId,
            languageCode: argument.languageCode
        )

        #expect(translation?.version == argument.expectedVersion)
    }

    @available(iOS 17.4, *)
    @Test(arguments: [
        LanguageCodeArgument(expectedVersion: 12, languageCode: "EN"),
        LanguageCodeArgument(expectedVersion: 122, languageCode: "Es")
    ])
    func getLatestTranslationByLanguageCodeIgnoresCase(argument: LanguageCodeArgument) throws {

        let translationsCache = try getCache()

        let translation = try translationsCache.getLatestTranslation(
            resourceId: argument.resourceId,
            languageCode: argument.languageCode
        )

        #expect(translation?.version == argument.expectedVersion)
    }

    @available(iOS 17.4, *)
    @Test(arguments: [
        MissingTranslationArgument(languageId: englishLanguageId, resourceId: "resource_does_not_exist"),
        MissingTranslationArgument(languageId: "language_does_not_exist")
    ])
    func getLatestTranslationByLanguageIdIsNil(argument: MissingTranslationArgument) throws {

        let translationsCache = try getCache()

        let translation = try translationsCache.getLatestTranslation(
            resourceId: argument.resourceId,
            languageId: argument.languageId
        )

        #expect(translation == nil)
    }

    @available(iOS 17.4, *)
    @Test
    func getLatestTranslationByLanguageCodeIsNil() throws {

        let translationsCache = try getCache()

        let translation = try translationsCache.getLatestTranslation(
            resourceId: Self.resourceId,
            languageCode: LanguageCodeDomainModel.czech.rawValue
        )

        #expect(translation == nil)
    }
}

// MARK: - Test Helpers

extension TranslationsCacheTests {

    @available(iOS 17.4, *)
    private func getCache() throws -> TranslationsCache {

        let testsAppConfig = TestsAppConfig(
            swiftDatabase: try FakeSwiftDatabase.createSwiftDatabase(addObjects: getSwiftDatabaseObjects())
        )

        let testsDiContainer = TestsDiContainer(testsAppConfig: testsAppConfig)

        return testsDiContainer.core.dataLayer.getTranslationsCache()
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

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [SwiftResource] {

        let english = SwiftLanguage.createNewFrom(model: getEnglishLanguage())
        let spanish = SwiftLanguage.createNewFrom(model: getSpanishLanguage())
        let vietnamese = SwiftLanguage.createNewFrom(model: getVietnameseLanguage())

        let resource = SwiftResource()
        resource.id = Self.resourceId
        resource.languages = [english, spanish, vietnamese]

        let translationsByLanguage: [(language: SwiftLanguage, translations: [TranslationDataModel])] = [
            (english, getEnglishTranslations()),
            (spanish, getSpanishTranslations()),
            (vietnamese, getVietnameseTranslations())
        ]

        for (language, translationModels) in translationsByLanguage {

            for translationModel in translationModels {

                let translation = SwiftTranslation.createNewFrom(model: translationModel)
                translation.language = language
                translation.resource = resource
                resource.latestTranslations.append(translation)
            }
        }

        return [resource]
    }
}
