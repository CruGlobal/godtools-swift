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
import RepositorySync
import Combine

@Suite(.serialized)
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
                
        let languagesCache: LanguagesCache = try getLanguagesCache()
        
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
                
        let languagesCache: LanguagesCache = try getLanguagesCache(
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
    func realmQueryLanguagesByCodes(argument: TestArgument) async  throws {
        
        let languagesCache: LanguagesCache = try getLanguagesCache()
        
        let languageCodes: [String] = argument.queryByLanguageCodes.map { $0.rawValue }
        
        var cancellables: Set<AnyCancellable> = Set()
        var languagesRef: [LanguageDataModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                languagesCache
                    .getCachedLanguagesPublisher(codes: languageCodes)
                    .sink { _ in
                        
                    } receiveValue: { (languages: [LanguageDataModel]) in
                        
                        languagesRef = languages
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                                
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                    .store(in: &cancellables)
            }
        }
                
        let languageIds: [String] = languagesRef.map { $0.id }

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
    func queryLanguagesByCodes(argument: TestArgument) async  throws {
        
        let languagesCache: LanguagesCache = try getLanguagesCache(
            swiftPersistenceIsEnabled: true
        )
        
        let languageCodes: [String] = argument.queryByLanguageCodes.map { $0.rawValue }
        
        let languages: [LanguageDataModel] = languagesCache.getCachedLanguages(codes: languageCodes)
        
        let languageIds: [String] = languages.map { $0.id }

        #expect(languageIds.sortedAscending() == argument.expectedLanguageIds.sortedAscending())
    }*/
}

extension LanguagesCacheTests {
    
    private func getTestsDiContainer(addRealmObjects: [IdentifiableRealmObject] = Array()) throws -> TestsDiContainer {
                
        return try TestsDiContainer(
            realmFileName: String(describing: LanguagesCacheTests.self),
            addRealmObjects: addRealmObjects
        )
    }
    
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
    
    private func getRealmDatabaseObjects() -> [IdentifiableRealmObject] {
        return allRealmLanguages
    }
    
    private func getLanguagesCache() throws -> LanguagesCache {
        
        let testsDiContainer = try getTestsDiContainer(addRealmObjects: getRealmDatabaseObjects())
        
        let persistence = RealmRepositorySyncPersistence(
            database: testsDiContainer.dataLayer.getSharedRealmDatabase(),
            dataModelMapping: RealmLanguageDataModelMapping()
        )
        
        return LanguagesCache(
            persistence: persistence
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
    private func getSwiftDatabase() throws -> SwiftDatabase {
        return try TestsInMemorySwiftDatabase().createDatabase(addObjectsToDatabase: getSwiftDatabaseObjects())
    }
}
