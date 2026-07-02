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
import RepositorySync

struct LanguagesCacheTests {
        
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
    func queryLanguageByCode(argument: TestArgument) async throws {
                
        let persistence = try await getPersistence()
        
        let cache = getCache(persistence: persistence)
        
        let languageCode: String = try #require(argument.queryByLanguageCodes.first?.rawValue)
                        
        let language: LanguageDataModel? = try cache.getLanguageByCode(code: languageCode)
        
        #expect(language?.id == argument.expectedLanguageIds.first)
    }

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
    func queryLanguagesByCodes(argument: TestArgument) async  throws {
        
        let persistence = try await getPersistence()
        
        let cache = getCache(persistence: persistence)
                
        let languageCodes: [String] = argument.queryByLanguageCodes.map { $0.rawValue }
                
        let languages: [LanguageDataModel] = try await cache.getLanguagesByCodes(codes: languageCodes)
                     
        let languageIds: [String] = languages.map { $0.id }

        #expect(languageIds.sortedAscending() == argument.expectedLanguageIds.sortedAscending())
    }
}

extension LanguagesCacheTests {
    
    private func getPersistence() async throws -> any Persistence<LanguageDataModel, LanguageCodable> {
        
        let databaseConfig = try RealmDatabaseConfig.createInMemoryConfig()
        
        let database = RealmDatabase(databaseConfig: databaseConfig)
        
        let persistence = RealmRepositorySyncPersistence(
            database: database,
            mapping: RealmLanguageMapping()
        )
        
        _ = try await persistence.writeObjects(
            externalObjects: getLanguages()
        )
                
        return persistence
    }
    
    private func getCache(persistence: any Persistence<LanguageDataModel, LanguageCodable>) -> LanguagesCache {
                
        return LanguagesCache(
            persistence: persistence
        )
    }
    
    private func getLanguages() -> [LanguageCodable] {
        
        return [
            LanguageCodable.create(id: "a", code: LanguageCodeDomainModel.arabic.rawValue),
            LanguageCodable.create(id: "b", code: LanguageCodeDomainModel.chinese.rawValue),
            LanguageCodable.create(id: "c", code: LanguageCodeDomainModel.english.rawValue),
            LanguageCodable.create(id: "d", code: LanguageCodeDomainModel.french.rawValue),
            LanguageCodable.create(id: "e", code: LanguageCodeDomainModel.hebrew.rawValue),
            LanguageCodable.create(id: "f", code: LanguageCodeDomainModel.latvian.rawValue),
            LanguageCodable.create(id: "g", code: LanguageCodeDomainModel.portuguese.rawValue),
            LanguageCodable.create(id: "h", code: LanguageCodeDomainModel.russian.rawValue),
            LanguageCodable.create(id: "i", code: LanguageCodeDomainModel.spanish.rawValue),
            LanguageCodable.create(id: "j", code: LanguageCodeDomainModel.vietnamese.rawValue),
            LanguageCodable.create(id: "k", code: LanguageCodeDomainModel.filipino.rawValue),
            LanguageCodable.create(id: "l", code: LanguageCodeDomainModel.finnish.rawValue)
        ]
    }
}
