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
import SwiftData

struct LanguagesCacheTests {
        
    @available(iOS 17.4, *)
    @Test
    func getLanguageByCode() async throws {
        
        let persistence = try await getPersistence()
        
        let cache = getCache(persistence: persistence)
                                
        let language: LanguageDataModel? = try cache.getLanguageByCode(code: LanguageCodeDomainModel.english.rawValue)
        
        #expect(language?.id == "c")
    }

    @available(iOS 17.4, *)
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

extension LanguagesCacheTests {
    
    @available(iOS 17.4, *)
    private func getPersistence() async throws -> SwiftRepositorySyncPersistence<LanguageDataModel, LanguageCodable, SwiftLanguage> {
        
        let container = try SwiftDataContainer.createInMemoryContainer(schema: Schema(versionedSchema: LatestProductionSwiftDataSchema.self))
        
        let database = SwiftDatabase(container: container)
        
        let persistence = SwiftRepositorySyncPersistence(
            database: database,
            mapping: SwiftLanguageMapping()
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
