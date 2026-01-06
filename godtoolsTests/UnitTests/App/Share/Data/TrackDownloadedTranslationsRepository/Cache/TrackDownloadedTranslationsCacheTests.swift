//
//  TrackDownloadedTranslationsCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 12/3/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import RealmSwift
import SwiftData
import RepositorySync

struct TrackDownloadedTranslationsCacheTests {
    
    private static let resourceAId: String = "resource_a"
    private static let resourceBId: String = "resource_b"
    private static let languageAId: String = "language_a"
    private static let languageBId: String = "language_b"
    private static let languageCId: String = "language_c"
    
    struct LatestDownloadedTranslationArgument {
        
        let resourceId: String
        let languageId: String
        let expectedIds: [String]
    }
    
    @Test(
        "",
        arguments: [
            LatestDownloadedTranslationArgument(
                resourceId: Self.resourceAId,
                languageId: Self.languageAId,
                expectedIds: ["a_a_25", "a_a_12", "a_a_8", "a_a_5", "a_a_1", "a_a_0"]
            ),
            LatestDownloadedTranslationArgument(
                resourceId: Self.resourceAId,
                languageId: Self.languageBId,
                expectedIds: ["a_b_20", "a_b_19", "a_b_10", "a_b_2"]
            ),
            LatestDownloadedTranslationArgument(
                resourceId: Self.resourceAId,
                languageId: Self.languageCId,
                expectedIds: ["a_c_51", "a_c_50"]
            )
        ]
    )
    func realmGetLatestDownloadedTranslationsByResourceIdAndLanguageId(argument: LatestDownloadedTranslationArgument) async {
        
        let trackDownloadedTranslationsCache = getTrackDownloadedTranslationsCache(
            swiftPersistenceIsEnabled: false
        )
        
        let translations: [DownloadedTranslationDataModel] = trackDownloadedTranslationsCache.getLatestDownloadedTranslations(
            resourceId: argument.resourceId,
            languageId: argument.languageId
        )
        
        let ids: [String] = translations.map { $0.id }
        
        #expect(ids.count == argument.expectedIds.count)
        #expect(ids == argument.expectedIds)
    }
    /*
    @Test(
        "",
        arguments: [
            LatestDownloadedTranslationArgument(
                resourceId: Self.resourceAId,
                languageId: Self.languageAId,
                expectedIds: ["a_a_25", "a_a_12", "a_a_8", "a_a_5", "a_a_1", "a_a_0"]
            ),
            LatestDownloadedTranslationArgument(
                resourceId: Self.resourceAId,
                languageId: Self.languageBId,
                expectedIds: ["a_b_20", "a_b_19", "a_b_10", "a_b_2"]
            ),
            LatestDownloadedTranslationArgument(
                resourceId: Self.resourceAId,
                languageId: Self.languageCId,
                expectedIds: ["a_c_51", "a_c_50"]
            )
        ]
    )
    func getLatestDownloadedTranslationsByResourceIdAndLanguageId(argument: LatestDownloadedTranslationArgument) async {
        
        let trackDownloadedTranslationsCache = getTrackDownloadedTranslationsCache(
            swiftPersistenceIsEnabled: true
        )
        
        let translations: [DownloadedTranslationDataModel] = trackDownloadedTranslationsCache.getLatestDownloadedTranslations(
            resourceId: argument.resourceId,
            languageId: argument.languageId
        )
        
        let ids: [String] = translations.map { $0.id }
        
        #expect(ids.count == argument.expectedIds.count)
        #expect(ids == argument.expectedIds)
    }*/
    
    @Test(
        "",
        arguments: [
            LatestDownloadedTranslationArgument(
                resourceId: Self.resourceAId,
                languageId: Self.languageAId,
                expectedIds: ["a_a_25"]
            ),
            LatestDownloadedTranslationArgument(
                resourceId: Self.resourceAId,
                languageId: Self.languageBId,
                expectedIds: ["a_b_20"]
            ),
            LatestDownloadedTranslationArgument(
                resourceId: Self.resourceAId,
                languageId: Self.languageCId,
                expectedIds: ["a_c_51"]
            )
        ]
    )
    func realmGetLatestDownloadedTranslationByResourceIdAndLanguageId(argument: LatestDownloadedTranslationArgument) async throws {
        
        let trackDownloadedTranslationsCache = getTrackDownloadedTranslationsCache(
            swiftPersistenceIsEnabled: false
        )
        
        let translation: DownloadedTranslationDataModel = try #require(trackDownloadedTranslationsCache.getLatestDownloadedTranslation(
            resourceId: argument.resourceId,
            languageId: argument.languageId
        ))
                
        #expect(translation.id == argument.expectedIds.first)
    }
    /*
    @Test(
        "",
        arguments: [
            LatestDownloadedTranslationArgument(
                resourceId: Self.resourceAId,
                languageId: Self.languageAId,
                expectedIds: ["a_a_25"]
            ),
            LatestDownloadedTranslationArgument(
                resourceId: Self.resourceAId,
                languageId: Self.languageBId,
                expectedIds: ["a_b_20"]
            ),
            LatestDownloadedTranslationArgument(
                resourceId: Self.resourceAId,
                languageId: Self.languageCId,
                expectedIds: ["a_c_51"]
            )
        ]
    )
    func getLatestDownloadedTranslationByResourceIdAndLanguageId(argument: LatestDownloadedTranslationArgument) async throws {
        
        let trackDownloadedTranslationsCache = getTrackDownloadedTranslationsCache(
            swiftPersistenceIsEnabled: true
        )
        
        let translation: DownloadedTranslationDataModel = try #require(trackDownloadedTranslationsCache.getLatestDownloadedTranslation(
            resourceId: argument.resourceId,
            languageId: argument.languageId
        ))
                
        #expect(translation.id == argument.expectedIds.first)
    }*/
}

extension TrackDownloadedTranslationsCacheTests {
    
    private func getTrackDownloadedTranslationsCache(swiftPersistenceIsEnabled: Bool) -> TrackDownloadedTranslationsCache {
    
        if #available(iOS 17.4, *), swiftPersistenceIsEnabled {
            TempSharedSwiftDatabase.shared.setDatabase(
                swiftDatabase: getSwiftDatabase()
            )
        }
        
        return TrackDownloadedTranslationsCache(
            realmDatabase: getLegacyRealmDatabase(),
            swiftPersistenceIsEnabled: swiftPersistenceIsEnabled
        )
    }
}

// MARK: - RealmDatabase

extension TrackDownloadedTranslationsCacheTests {
    
    private func getRealmDatabaseObjects() -> [Object] {
        return getMockTrackDownloadedTranslations()
            .map {
                RealmDownloadedTranslation.createNewFrom(interface: $0)
            }
    }
    
    private func getLegacyRealmDatabase() -> LegacyRealmDatabase {
        return TestsInMemoryRealmDatabase(
            addObjectsToDatabase: getRealmDatabaseObjects()
        )
    }
}

// MARK: - SwiftDatabase

extension TrackDownloadedTranslationsCacheTests {
    
    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any IdentifiableSwiftDataObject] {
        return getMockTrackDownloadedTranslations()
            .map {
                SwiftDownloadedTranslation.createNewFrom(interface: $0)
            }
    }
    
    @available(iOS 17.4, *)
    private func getSwiftDatabase() -> godtools.SwiftDatabase {
        return TestsInMemorySwiftDatabase(
            addObjectsToDatabase: getSwiftDatabaseObjects()
        )
    }
}

// MARK: - Mock Data

extension TrackDownloadedTranslationsCacheTests {
    
    private func getMockTrackDownloadedTranslations() -> [MockDownloadedTranslation] {
        
        let resourcesA: [MockDownloadedTranslation] = [
            MockDownloadedTranslation(
                resourceId: Self.resourceAId,
                languageId: Self.languageAId,
                version: 0,
                id: "a_a_0"
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceAId,
                languageId: Self.languageAId,
                version: 1,
                id: "a_a_1"
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceAId,
                languageId: Self.languageAId,
                version: 5,
                id: "a_a_5"
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceAId,
                languageId: Self.languageAId,
                version: 8,
                id: "a_a_8"
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceAId,
                languageId: Self.languageAId,
                version: 12,
                id: "a_a_12"
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceAId,
                languageId: Self.languageAId,
                version: 25,
                id: "a_a_25"
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceAId,
                languageId: Self.languageBId,
                version: 20,
                id: "a_b_20"
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceAId,
                languageId: Self.languageBId,
                version: 19,
                id: "a_b_19"
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceAId,
                languageId: Self.languageBId,
                version: 2,
                id: "a_b_2"
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceAId,
                languageId: Self.languageBId,
                version: 10,
                id: "a_b_10"
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceAId,
                languageId: Self.languageCId,
                version: 50,
                id: "a_c_50"
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceAId,
                languageId: Self.languageCId,
                version: 51,
                id: "a_c_51"
            )
        ]
        
        let resourcesB: [MockDownloadedTranslation] = [
            MockDownloadedTranslation(
                resourceId: Self.resourceBId,
                languageId: Self.languageAId,
                version: 44
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceBId,
                languageId: Self.languageAId,
                version: 1
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceBId,
                languageId: Self.languageAId,
                version: 10
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceBId,
                languageId: Self.languageAId,
                version: 8
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceBId,
                languageId: Self.languageAId,
                version: 22
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceBId,
                languageId: Self.languageAId,
                version: 0
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceBId,
                languageId: Self.languageCId,
                version: 1
            ),
            MockDownloadedTranslation(
                resourceId: Self.resourceBId,
                languageId: Self.languageCId,
                version: 30
            )
        ]
        
        return resourcesA + resourcesB
    }
}
