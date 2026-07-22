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

    struct DownloadedLanguagesByDownloadCompleteArgument {

        let downloadComplete: Bool
        let expectedLanguageIds: Set<String>
    }

    // MARK: - Query

    @available(iOS 17.4, *)
    @Test(arguments: [
        DownloadedLanguagesByDownloadCompleteArgument(
            downloadComplete: true,
            expectedLanguageIds: ["a", "c", "e"]
        ),
        DownloadedLanguagesByDownloadCompleteArgument(
            downloadComplete: false,
            expectedLanguageIds: ["b", "d"]
        )
    ])
    func getDownloadedLanguagesByDownloadComplete(argument: DownloadedLanguagesByDownloadCompleteArgument) async throws {

        let cache = try getCache()

        let downloadedLanguages: [DownloadedLanguageDataModel] = try await cache.getDownloadedLanguagesByDownloadComplete(
            downloadComplete: argument.downloadComplete
        )

        let languageIds: Set<String> = Set(downloadedLanguages.map { $0.languageId })

        #expect(languageIds == argument.expectedLanguageIds)
    }

    @available(iOS 17.4, *)
    @Test
    func getDownloadedLanguagesByDownloadCompleteIsEmpty() async throws {

        let cache = try getCache(downloadedLanguages: [])

        let downloadedLanguages: [DownloadedLanguageDataModel] = try await cache.getDownloadedLanguagesByDownloadComplete(
            downloadComplete: true
        )

        #expect(downloadedLanguages.isEmpty)
    }

    // MARK: - Delete

    @available(iOS 17.4, *)
    @Test
    func deleteDownloadedLanguageRemovesLanguage() async throws {

        let cache = try getCache()

        try await cache.deleteDownloadedLanguage(languageId: "c")

        let downloadCompleteLanguages: [DownloadedLanguageDataModel] = try await cache.getDownloadedLanguagesByDownloadComplete(
            downloadComplete: true
        )

        let languageIds: Set<String> = Set(downloadCompleteLanguages.map { $0.languageId })

        #expect(languageIds == ["a", "e"])
    }

    @available(iOS 17.4, *)
    @Test
    func deleteDownloadedLanguageKeepsOtherLanguages() async throws {

        let cache = try getCache()

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
    private func getCache(downloadedLanguages: [DownloadedLanguageDataModel]? = nil) throws -> DownloadedLanguagesCache {

        let downloadedLanguagesToStore: [DownloadedLanguageDataModel] = downloadedLanguages ?? getDownloadedLanguages()

        let testsAppConfig = TestsAppConfig(
            swiftDatabase: try FakeSwiftDatabase.createSwiftDatabase(addObjects: getSwiftDatabaseObjects(downloadedLanguages: downloadedLanguagesToStore))
        )

        let testsDiContainer = TestsDiContainer(testsAppConfig: testsAppConfig)

        return testsDiContainer.feature.appLanguage.dataLayer.getDownloadedLanguagesCache()
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects(downloadedLanguages: [DownloadedLanguageDataModel]) -> [SwiftDownloadedLanguage] {
        return downloadedLanguages.map { SwiftDownloadedLanguage.createNewFrom(model: $0) }
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
