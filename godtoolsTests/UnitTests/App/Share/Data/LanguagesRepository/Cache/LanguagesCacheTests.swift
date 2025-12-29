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
import SwiftData

struct LanguagesCacheTests {
        
    struct TestLanguage {
        let id: String
        let code: LanguageCodeDomainModel
    }
    
    struct TestArgument {
        let queryByLanguageCodes: [LanguageCodeDomainModel]
        let expectedLanguageIds: [String]
    }
    
    @Test(arguments: [
        TestArgument(
            queryByLanguageCodes: [LanguageCodeDomainModel.english],
            expectedLanguageIds: ["c"]
        ),
        TestArgument(
            queryByLanguageCodes: [LanguageCodeDomainModel.spanish],
            expectedLanguageIds: ["i"]
        ),
        TestArgument(
            queryByLanguageCodes: [LanguageCodeDomainModel.finnish],
            expectedLanguageIds: ["l"]
        )
    ])
    func realmQueryLanguageByCode(argument: TestArgument) async throws {
                
        let languagesCache: LanguagesCache = getLanguagesCache(
            swiftPersistenceIsEnabled: false
        )
        
        let languageCode: String = try #require(argument.queryByLanguageCodes.first?.rawValue)
                        
        let language: LanguageDataModel? = languagesCache.getCachedLanguage(code: languageCode)
        
        #expect(language?.id == argument.expectedLanguageIds.first)
    }
    /*
    @Test(arguments: [
        TestArgument(
            queryByLanguageCodes: [LanguageCodeDomainModel.english],
            expectedLanguageIds: ["c"]
        ),
        TestArgument(
            queryByLanguageCodes: [LanguageCodeDomainModel.spanish],
            expectedLanguageIds: ["i"]
        ),
        TestArgument(
            queryByLanguageCodes: [LanguageCodeDomainModel.finnish],
            expectedLanguageIds: ["l"]
        )
    ])
    func queryLanguageByCode(argument: TestArgument) async throws {
                
        let languagesCache: LanguagesCache = getLanguagesCache(
            swiftPersistenceIsEnabled: true
        )
        
        let languageCode: String = try #require(argument.queryByLanguageCodes.first?.rawValue)
                        
        let language: LanguageDataModel? = languagesCache.getCachedLanguage(code: languageCode)
        
        #expect(language?.id == argument.expectedLanguageIds.first)
    }*/
    
    @Test(arguments: [
        TestArgument(
            queryByLanguageCodes: [LanguageCodeDomainModel.english, LanguageCodeDomainModel.spanish],
            expectedLanguageIds: ["c", "i"]
        ),
        TestArgument(
            queryByLanguageCodes: [LanguageCodeDomainModel.russian, LanguageCodeDomainModel.vietnamese, LanguageCodeDomainModel.french, LanguageCodeDomainModel.chinese],
            expectedLanguageIds: ["j", "b", "d", "h"]
        ),
        TestArgument(
            queryByLanguageCodes: [],
            expectedLanguageIds: []
        )
    ])
    func realmQueryLanguagesByCodes(argument: TestArgument) async {
        
        let languagesCache: LanguagesCache = getLanguagesCache(
            swiftPersistenceIsEnabled: false
        )
        
        let languageCodes: [String] = argument.queryByLanguageCodes.map { $0.rawValue }
        
        let languages: [LanguageDataModel] = languagesCache.getCachedLanguages(codes: languageCodes)
        
        let languageIds: [String] = languages.map { $0.id }

        #expect(languageIds.sortedAscending() == argument.expectedLanguageIds.sortedAscending())
    }
    /*
    @Test(arguments: [
        TestArgument(
            queryByLanguageCodes: [LanguageCodeDomainModel.english, LanguageCodeDomainModel.spanish],
            expectedLanguageIds: ["c", "i"]
        ),
        TestArgument(
            queryByLanguageCodes: [LanguageCodeDomainModel.russian, LanguageCodeDomainModel.vietnamese, LanguageCodeDomainModel.french, LanguageCodeDomainModel.chinese],
            expectedLanguageIds: ["j", "b", "d", "h"]
        ),
        TestArgument(
            queryByLanguageCodes: [],
            expectedLanguageIds: []
        )
    ])
    func queryLanguagesByCodes(argument: TestArgument) async {
        
        let languagesCache: LanguagesCache = getLanguagesCache(
            swiftPersistenceIsEnabled: true
        )
        
        let languageCodes: [String] = argument.queryByLanguageCodes.map { $0.rawValue }
        
        let languages: [LanguageDataModel] = languagesCache.getCachedLanguages(codes: languageCodes)
        
        let languageIds: [String] = languages.map { $0.id }

        #expect(languageIds.sortedAscending() == argument.expectedLanguageIds.sortedAscending())
    }*/
}

extension LanguagesCacheTests {
    
    private var allTestLanguages: [TestLanguage] {
        return [
            TestLanguage(id: "a", code: LanguageCodeDomainModel.arabic),
            TestLanguage(id: "b", code: LanguageCodeDomainModel.chinese),
            TestLanguage(id: "c", code: LanguageCodeDomainModel.english),
            TestLanguage(id: "d", code: LanguageCodeDomainModel.french),
            TestLanguage(id: "e", code: LanguageCodeDomainModel.hebrew),
            TestLanguage(id: "f", code: LanguageCodeDomainModel.latvian),
            TestLanguage(id: "g", code: LanguageCodeDomainModel.portuguese),
            TestLanguage(id: "h", code: LanguageCodeDomainModel.russian),
            TestLanguage(id: "i", code: LanguageCodeDomainModel.spanish),
            TestLanguage(id: "j", code: LanguageCodeDomainModel.vietnamese),
            TestLanguage(id: "k", code: LanguageCodeDomainModel.filipino),
            TestLanguage(id: "l", code: LanguageCodeDomainModel.finnish)
        ]
    }
    
    private var allRealmLanguages: [RealmLanguage] {
        return allTestLanguages.map {
            MockRealmLanguage.createLanguage(
                language: $0.code,
                name: $0.code.rawValue,
                id: $0.id
            )
        }
    }
    
    private func getLanguagesCache(swiftPersistenceIsEnabled: Bool) -> LanguagesCache {
        
        if #available(iOS 17.4, *), swiftPersistenceIsEnabled {
            TempSharedSwiftDatabase.shared.setDatabase(
                swiftDatabase: getSwiftDatabase()
            )
        }
        
        return LanguagesCache(
            realmDatabase: getLegacyRealmDatabase(),
            swiftPersistenceIsEnabled: swiftPersistenceIsEnabled
        )
    }
}

// MARK: - RealmDatabase

extension LanguagesCacheTests {
    
    private func getRealmDatabaseObjects() -> [Object] {
        return allRealmLanguages
    }
    
    private func getLegacyRealmDatabase() -> LegacyRealmDatabase {
        return TestsInMemoryRealmDatabase(
            addObjectsToDatabase: getRealmDatabaseObjects()
        )
    }
}

// MARK: - SwiftDatabase

extension LanguagesCacheTests {
    
    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any IdentifiableSwiftDataObject] {
        return allRealmLanguages.map {
            SwiftLanguage.createNewFrom(
                interface: $0
            )
        }
    }
    
    @available(iOS 17.4, *)
    private func getSwiftDatabase() -> SwiftDatabase {
        return TestsInMemorySwiftDatabase(
            addObjectsToDatabase: getSwiftDatabaseObjects()
        )
    }
}
