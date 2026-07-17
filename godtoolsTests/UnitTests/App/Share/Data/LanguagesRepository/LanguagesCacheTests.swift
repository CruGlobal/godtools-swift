//
//  LanguagesCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import RealmSwift
import RepositorySync
import SwiftData

struct LanguagesCacheTests {

    enum PersistenceType: CaseIterable {
        case realm
        case swiftData
    }

    @available(iOS 17.4, *)
    @Test(arguments: PersistenceType.allCases)
    func getLanguageByCodeExists(persistenceType: PersistenceType) async throws {

        let cache = try getCache(persistenceType: persistenceType)

        let language: LanguageDataModel? = try cache.getLanguageByCode(code: LanguageCodeDomainModel.english.rawValue)

        #expect(language?.id == "c")
    }

    @available(iOS 17.4, *)
    @Test(arguments: PersistenceType.allCases)
    func getLanguageByCodeIsNil(persistenceType: PersistenceType) async throws {

        let cache = try getCache(persistenceType: persistenceType)

        let language: LanguageDataModel? = try cache.getLanguageByCode(code: "no_language_code")

        #expect(language == nil)
    }

    @available(iOS 17.4, *)
    @Test(arguments: PersistenceType.allCases)
    func getLanguagesByCodes(persistenceType: PersistenceType) async throws {

        let cache = try getCache(persistenceType: persistenceType)

        let languageCodes = [
            LanguageCodeDomainModel.russian,
            LanguageCodeDomainModel.vietnamese,
            LanguageCodeDomainModel.french,
            LanguageCodeDomainModel.chinese
        ]

        let languages: [LanguageDataModel] = try await cache.getLanguagesByCodes(codes: languageCodes.map { $0.rawValue })

        let languageIds: Set<String> = Set(languages.map { $0.id })

        #expect(languageIds == ["j", "b", "d", "h"])
    }
}

// MARK: - Test Helpers

extension LanguagesCacheTests {

    @available(iOS 17.4, *)
    private func getCache(persistenceType: PersistenceType) throws -> LanguagesCache {

        let testsAppConfig: TestsAppConfig

        switch persistenceType {
        case .realm:
            testsAppConfig = TestsAppConfig(
                realmDatabase: try FakeRealmDatabase.createRealmDatabase(addRealmObjects: getRealmDatabaseObjects()),
                swiftDatabase: nil
            )

        case .swiftData:
            testsAppConfig = TestsAppConfig(
                realmDatabase: nil,
                swiftDatabase: try FakeSwiftDatabase.createSwiftDatabase(addObjects: getSwiftDatabaseObjects())
            )
        }

        let testsDiContainer = TestsDiContainer(testsAppConfig: testsAppConfig)

        return testsDiContainer.core.dataLayer.getLanguagesCache()
    }

    private func getRealmDatabaseObjects() -> [IdentifiableRealmObject] {
        return getLanguages().map { RealmLanguage.createNewFrom(model: $0.toModel()) }
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [SwiftLanguage] {
        return getLanguages().map { SwiftLanguage.createNewFrom(model: $0.toModel()) }
    }

    private func getLanguages() -> [LanguageCodable] {

        return [
            LanguageCodable.random(id: "a", code: LanguageCodeDomainModel.arabic.rawValue),
            LanguageCodable.random(id: "b", code: LanguageCodeDomainModel.chinese.rawValue),
            LanguageCodable.random(id: "c", code: LanguageCodeDomainModel.english.rawValue),
            LanguageCodable.random(id: "d", code: LanguageCodeDomainModel.french.rawValue),
            LanguageCodable.random(id: "e", code: LanguageCodeDomainModel.hebrew.rawValue),
            LanguageCodable.random(id: "f", code: LanguageCodeDomainModel.latvian.rawValue),
            LanguageCodable.random(id: "g", code: LanguageCodeDomainModel.portuguese.rawValue),
            LanguageCodable.random(id: "h", code: LanguageCodeDomainModel.russian.rawValue),
            LanguageCodable.random(id: "i", code: LanguageCodeDomainModel.spanish.rawValue),
            LanguageCodable.random(id: "j", code: LanguageCodeDomainModel.vietnamese.rawValue),
            LanguageCodable.random(id: "k", code: LanguageCodeDomainModel.filipino.rawValue),
            LanguageCodable.random(id: "l", code: LanguageCodeDomainModel.finnish.rawValue)
        ]
    }
}
