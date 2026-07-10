//
//  RealmLanguagesCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import RepositorySync

struct RealmLanguagesCacheTests {
        
    @Test
    func getLanguageByCode() async throws {
        
        let persistence = try await getPersistence()
        
        let cache = getCache(persistence: persistence)
                                
        let language: LanguageDataModel? = try cache.getLanguageByCode(code: LanguageCodeDomainModel.english.rawValue)
        
        #expect(language?.id == "c")
    }

    @Test
    func getLanguagesByCodes() async  throws {
        
        let persistence = try await getPersistence()
        
        let cache = getCache(persistence: persistence)
        
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

extension RealmLanguagesCacheTests {
    
    private func getPersistence() async throws -> RealmRepositorySyncPersistence<LanguageDataModel, LanguageCodable, RealmLanguage> {
        
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
