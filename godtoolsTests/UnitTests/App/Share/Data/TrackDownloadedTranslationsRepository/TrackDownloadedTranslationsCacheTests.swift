//
//  TrackDownloadedTranslationsCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import RepositorySync
import SwiftData

struct TrackDownloadedTranslationsCacheTests {

    private static let resourceAId: String = "resource_a"
    private static let resourceBId: String = "resource_b"
    private static let languageAId: String = "language_a"
    private static let languageBId: String = "language_b"
    private static let languageCId: String = "language_c"

    enum PersistenceType: CaseIterable {
        case realm
        case swiftData
    }

    struct LatestDownloadedTranslationsArgument {

        let resourceId: String
        let languageId: String
        let expectedIds: [String]
    }

    // MARK: - Query

    @available(iOS 17.4, *)
    @Test(arguments: PersistenceType.allCases, [
        LatestDownloadedTranslationsArgument(
            resourceId: Self.resourceAId,
            languageId: Self.languageAId,
            expectedIds: ["a_a_25", "a_a_12", "a_a_8", "a_a_5", "a_a_1", "a_a_0"]
        ),
        LatestDownloadedTranslationsArgument(
            resourceId: Self.resourceAId,
            languageId: Self.languageBId,
            expectedIds: ["a_b_20", "a_b_19", "a_b_10", "a_b_2"]
        ),
        LatestDownloadedTranslationsArgument(
            resourceId: Self.resourceBId,
            languageId: Self.languageAId,
            expectedIds: ["b_a_7", "b_a_3"]
        ),
        LatestDownloadedTranslationsArgument(
            resourceId: Self.resourceBId,
            languageId: Self.languageCId,
            expectedIds: []
        )
    ])
    func getLatestDownloadedTranslationsSortedByLatestVersion(persistenceType: PersistenceType, argument: LatestDownloadedTranslationsArgument) async throws {

        let cache = try await getCache(persistenceType: persistenceType)

        let downloadedTranslations: [DownloadedTranslationDataModel] = try await cache.getLatestDownloadedTranslations(
            resourceId: argument.resourceId,
            languageId: argument.languageId
        )

        #expect(downloadedTranslations.map { $0.id } == argument.expectedIds)
    }

    @available(iOS 17.4, *)
    @Test(arguments: PersistenceType.allCases)
    func getLatestDownloadedTranslationExists(persistenceType: PersistenceType) async throws {

        let cache = try await getCache(persistenceType: persistenceType)

        let downloadedTranslation: DownloadedTranslationDataModel? = try cache.getLatestDownloadedTranslation(
            resourceId: Self.resourceAId,
            languageId: Self.languageAId
        )

        #expect(downloadedTranslation?.id == "a_a_25")
        #expect(downloadedTranslation?.version == 25)
    }

    @available(iOS 17.4, *)
    @Test(arguments: PersistenceType.allCases)
    func getLatestDownloadedTranslationIsNil(persistenceType: PersistenceType) async throws {

        let cache = try await getCache(persistenceType: persistenceType)

        let downloadedTranslation: DownloadedTranslationDataModel? = try cache.getLatestDownloadedTranslation(
            resourceId: Self.resourceBId,
            languageId: Self.languageCId
        )

        #expect(downloadedTranslation == nil)
    }

    // MARK: - Track Downloads

    @available(iOS 17.4, *)
    @Test(arguments: PersistenceType.allCases)
    func trackTranslationDownloadedPersistsDownloadedTranslation(persistenceType: PersistenceType) async throws {

        let cache = try await getCache(persistenceType: persistenceType)

        let translation: TranslationDataModel = TranslationCodable.random(
            id: "b_c_30",
            language: LanguageCodable.random(id: Self.languageCId, code: LanguageCodeDomainModel.english.rawValue),
            resource: ResourceCodable.random(id: Self.resourceBId),
            version: 30
        ).toModel()

        let trackedTranslations: [DownloadedTranslationDataModel] = try await cache.trackTranslationDownloaded(translation: translation)

        let downloadedTranslation: DownloadedTranslationDataModel? = try cache.getLatestDownloadedTranslation(
            resourceId: Self.resourceBId,
            languageId: Self.languageCId
        )

        #expect(trackedTranslations.map { $0.id } == ["b_c_30"])
        #expect(downloadedTranslation?.id == "b_c_30")
        #expect(downloadedTranslation?.translationId == "b_c_30")
        #expect(downloadedTranslation?.resourceId == Self.resourceBId)
        #expect(downloadedTranslation?.languageId == Self.languageCId)
        #expect(downloadedTranslation?.version == 30)
        #expect(downloadedTranslation?.manifestAndRelatedFilesPersistedToDevice == true)
    }

    @available(iOS 17.4, *)
    @Test(arguments: PersistenceType.allCases)
    func trackTranslationDownloadedTracksLatestVersion(persistenceType: PersistenceType) async throws {

        let cache = try await getCache(persistenceType: persistenceType)

        let translation: TranslationDataModel = TranslationCodable.random(
            id: "a_a_26",
            language: LanguageCodable.random(id: Self.languageAId, code: LanguageCodeDomainModel.english.rawValue),
            resource: ResourceCodable.random(id: Self.resourceAId),
            version: 26
        ).toModel()

        _ = try await cache.trackTranslationDownloaded(translation: translation)

        let downloadedTranslation: DownloadedTranslationDataModel? = try cache.getLatestDownloadedTranslation(
            resourceId: Self.resourceAId,
            languageId: Self.languageAId
        )

        #expect(downloadedTranslation?.id == "a_a_26")
        #expect(downloadedTranslation?.version == 26)
    }

    @available(iOS 17.4, *)
    @Test(arguments: PersistenceType.allCases)
    func trackTranslationDownloadedThrowsWhenResourceIsMissing(persistenceType: PersistenceType) async throws {

        let cache = try await getCache(persistenceType: persistenceType)

        let translation: TranslationDataModel = TranslationCodable.random(
            language: LanguageCodable.random(id: Self.languageAId, code: LanguageCodeDomainModel.english.rawValue),
            resource: nil
        ).toModel()

        await #expect(throws: (any Error).self) {
            _ = try await cache.trackTranslationDownloaded(translation: translation)
        }
    }

    @available(iOS 17.4, *)
    @Test(arguments: PersistenceType.allCases)
    func trackTranslationDownloadedThrowsWhenLanguageIsMissing(persistenceType: PersistenceType) async throws {

        let cache = try await getCache(persistenceType: persistenceType)

        let translation: TranslationDataModel = TranslationCodable.random(
            language: nil,
            resource: ResourceCodable.random(id: Self.resourceAId)
        ).toModel()

        await #expect(throws: (any Error).self) {
            _ = try await cache.trackTranslationDownloaded(translation: translation)
        }
    }
}

// MARK: - Test Helpers

extension TrackDownloadedTranslationsCacheTests {

    @available(iOS 17.4, *)
    private func getCache(persistenceType: PersistenceType) async throws -> TrackDownloadedTranslationsCache {

        let persistence: any Persistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel>

        switch persistenceType {

        case .realm:
            persistence = try getRealmPersistence()

        case .swiftData:
            persistence = try getSwiftPersistence()
        }

        try await persistence.writeObjects(
            externalObjects: getDownloadedTranslations()
        )

        return TrackDownloadedTranslationsCache(
            persistence: persistence
        )
    }

    private func getRealmPersistence() throws -> RealmRepositorySyncPersistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel, RealmDownloadedTranslation> {

        return RealmRepositorySyncPersistence(
            database: try FakeRealmDatabase.createRealmDatabase(),
            mapping: RealmDownloadedTranslationMapping()
        )
    }

    @available(iOS 17.4, *)
    private func getSwiftPersistence() throws -> SwiftRepositorySyncPersistence<DownloadedTranslationDataModel, DownloadedTranslationDataModel, SwiftDownloadedTranslation> {

        let container = try SwiftDataContainer.createInMemoryContainer(schema: Schema(versionedSchema: LatestProductionSwiftDataSchema.self))

        return SwiftRepositorySyncPersistence(
            database: SwiftDatabase(container: container),
            mapping: SwiftDownloadedTranslationMapping()
        )
    }

    private func getDownloadedTranslations() -> [DownloadedTranslationDataModel] {

        return [
            getDownloadedTranslation(id: "a_a_5", resourceId: Self.resourceAId, languageId: Self.languageAId, version: 5),
            getDownloadedTranslation(id: "a_a_25", resourceId: Self.resourceAId, languageId: Self.languageAId, version: 25),
            getDownloadedTranslation(id: "a_a_0", resourceId: Self.resourceAId, languageId: Self.languageAId, version: 0),
            getDownloadedTranslation(id: "a_a_12", resourceId: Self.resourceAId, languageId: Self.languageAId, version: 12),
            getDownloadedTranslation(id: "a_a_1", resourceId: Self.resourceAId, languageId: Self.languageAId, version: 1),
            getDownloadedTranslation(id: "a_a_8", resourceId: Self.resourceAId, languageId: Self.languageAId, version: 8),

            getDownloadedTranslation(id: "a_b_19", resourceId: Self.resourceAId, languageId: Self.languageBId, version: 19),
            getDownloadedTranslation(id: "a_b_2", resourceId: Self.resourceAId, languageId: Self.languageBId, version: 2),
            getDownloadedTranslation(id: "a_b_20", resourceId: Self.resourceAId, languageId: Self.languageBId, version: 20),
            getDownloadedTranslation(id: "a_b_10", resourceId: Self.resourceAId, languageId: Self.languageBId, version: 10),

            getDownloadedTranslation(id: "b_a_3", resourceId: Self.resourceBId, languageId: Self.languageAId, version: 3),
            getDownloadedTranslation(id: "b_a_7", resourceId: Self.resourceBId, languageId: Self.languageAId, version: 7)
        ]
    }

    private func getDownloadedTranslation(id: String, resourceId: String, languageId: String, version: Int) -> DownloadedTranslationDataModel {

        return DownloadedTranslationDataModel(
            id: id,
            languageId: languageId,
            manifestAndRelatedFilesPersistedToDevice: true,
            resourceId: resourceId,
            translationId: id,
            version: version
        )
    }
}
