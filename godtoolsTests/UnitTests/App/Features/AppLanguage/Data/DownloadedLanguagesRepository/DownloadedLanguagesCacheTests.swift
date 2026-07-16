//
//  DownloadedLanguagesCacheTests.swift
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

struct DownloadedLanguagesCacheTests {

    enum PersistenceType: CaseIterable {
        case realm
        case swiftData
    }

    struct DownloadedLanguagesByDownloadCompleteArgument {

        let downloadComplete: Bool
        let expectedLanguageIds: Set<String>
    }

    // MARK: - Query

    @available(iOS 17.4, *)
    @Test(arguments: PersistenceType.allCases, [
        DownloadedLanguagesByDownloadCompleteArgument(
            downloadComplete: true,
            expectedLanguageIds: ["a", "c", "e"]
        ),
        DownloadedLanguagesByDownloadCompleteArgument(
            downloadComplete: false,
            expectedLanguageIds: ["b", "d"]
        )
    ])
    func getDownloadedLanguagesByDownloadComplete(persistenceType: PersistenceType, argument: DownloadedLanguagesByDownloadCompleteArgument) async throws {

        let cache = try await getCache(persistenceType: persistenceType)

        let downloadedLanguages: [DownloadedLanguageDataModel] = try await cache.getDownloadedLanguagesByDownloadComplete(
            downloadComplete: argument.downloadComplete
        )

        let languageIds: Set<String> = Set(downloadedLanguages.map { $0.languageId })

        #expect(languageIds == argument.expectedLanguageIds)
    }

    @available(iOS 17.4, *)
    @Test(arguments: PersistenceType.allCases)
    func getDownloadedLanguagesByDownloadCompleteIsEmpty(persistenceType: PersistenceType) async throws {

        let cache = try await getCache(persistenceType: persistenceType, downloadedLanguages: [])

        let downloadedLanguages: [DownloadedLanguageDataModel] = try await cache.getDownloadedLanguagesByDownloadComplete(
            downloadComplete: true
        )

        #expect(downloadedLanguages.isEmpty)
    }

    // MARK: - Delete

    @available(iOS 17.4, *)
    @Test(arguments: PersistenceType.allCases)
    func deleteDownloadedLanguageRemovesLanguage(persistenceType: PersistenceType) async throws {

        let cache = try await getCache(persistenceType: persistenceType)

        try await cache.deleteDownloadedLanguage(languageId: "c")

        let downloadCompleteLanguages: [DownloadedLanguageDataModel] = try await cache.getDownloadedLanguagesByDownloadComplete(
            downloadComplete: true
        )

        let languageIds: Set<String> = Set(downloadCompleteLanguages.map { $0.languageId })

        #expect(languageIds == ["a", "e"])
    }

    @available(iOS 17.4, *)
    @Test(arguments: PersistenceType.allCases)
    func deleteDownloadedLanguageKeepsOtherLanguages(persistenceType: PersistenceType) async throws {

        let cache = try await getCache(persistenceType: persistenceType)

        try await cache.deleteDownloadedLanguage(languageId: "b")

        let downloadCompleteLanguages: [DownloadedLanguageDataModel] = try await cache.getDownloadedLanguagesByDownloadComplete(
            downloadComplete: true
        )

        let downloadIncompleteLanguages: [DownloadedLanguageDataModel] = try await cache.getDownloadedLanguagesByDownloadComplete(
            downloadComplete: false
        )

        #expect(Set(downloadCompleteLanguages.map { $0.languageId }) == ["a", "c", "e"])
        #expect(Set(downloadIncompleteLanguages.map { $0.languageId }) == ["d"])
    }
}

// MARK: - Test Helpers

extension DownloadedLanguagesCacheTests {

    @available(iOS 17.4, *)
    private func getCache(persistenceType: PersistenceType, downloadedLanguages: [DownloadedLanguageDataModel]? = nil) async throws -> DownloadedLanguagesCache {

        let persistence: any Persistence<DownloadedLanguageDataModel, DownloadedLanguageDataModel>

        switch persistenceType {

        case .realm:
            persistence = try getRealmPersistence()

        case .swiftData:
            persistence = try getSwiftPersistence()
        }

        try await persistence.writeObjects(
            externalObjects: downloadedLanguages ?? getDownloadedLanguages()
        )

        return DownloadedLanguagesCache(
            persistence: persistence
        )
    }

    private func getRealmPersistence() throws -> RealmRepositorySyncPersistence<DownloadedLanguageDataModel, DownloadedLanguageDataModel, RealmDownloadedLanguage> {

        return RealmRepositorySyncPersistence(
            database: try FakeRealmDatabase.createRealmDatabase(),
            mapping: RealmDownloadedLanguageMapping()
        )
    }

    @available(iOS 17.4, *)
    private func getSwiftPersistence() throws -> SwiftRepositorySyncPersistence<DownloadedLanguageDataModel, DownloadedLanguageDataModel, SwiftDownloadedLanguage> {

        let container = try SwiftDataContainer.createInMemoryContainer(schema: Schema(versionedSchema: LatestProductionSwiftDataSchema.self))

        return SwiftRepositorySyncPersistence(
            database: SwiftDatabase(container: container),
            mapping: SwiftDownloadedLanguageMapping()
        )
    }

    private func getDownloadedLanguages() -> [DownloadedLanguageDataModel] {

        return [
            getDownloadedLanguage(languageId: "a", downloadComplete: true),
            getDownloadedLanguage(languageId: "b", downloadComplete: false),
            getDownloadedLanguage(languageId: "c", downloadComplete: true),
            getDownloadedLanguage(languageId: "d", downloadComplete: false),
            getDownloadedLanguage(languageId: "e", downloadComplete: true)
        ]
    }

    private func getDownloadedLanguage(languageId: String, downloadComplete: Bool) -> DownloadedLanguageDataModel {

        return DownloadedLanguageDataModel(
            languageId: languageId,
            downloadComplete: downloadComplete,
            createdAt: Date()
        )
    }
}
