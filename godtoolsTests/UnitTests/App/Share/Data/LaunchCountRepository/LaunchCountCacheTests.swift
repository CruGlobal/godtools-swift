//
//  LaunchCountCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 8/11/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import Combine
import RepositorySync
import SwiftData

struct LaunchCountCacheTests {

    @available(iOS 17.4, *)
    @Test
    func getLaunchCountIsZeroWhenLaunchCountIsNotStored() throws {

        let cache = try getCache()

        #expect(cache.getLaunchCount() == 0)
    }

    @available(iOS 17.4, *)
    @Test(arguments: [1, 7, 1000])
    func storeLaunchCountPersistsLaunchCount(launchCount: Int) async throws {

        let cache = try getCache()

        try await cache.storeLaunchCount(count: launchCount)

        #expect(cache.getLaunchCount() == launchCount)
    }

    @available(iOS 17.4, *)
    @Test
    func storeLaunchCountReplacesPreviouslyStoredLaunchCount() async throws {

        let cache = try getCache()

        try await cache.storeLaunchCount(count: 3)
        try await cache.storeLaunchCount(count: 4)
        try await cache.storeLaunchCount(count: 5)

        #expect(cache.getLaunchCount() == 5)
    }

    @available(iOS 17.4, *)
    @Test
    func launchCountPersistsAcrossCacheInstances() async throws {

        let dataLayer = try getDataLayer()

        try await dataLayer.getLaunchCountCache().storeLaunchCount(count: 12)

        #expect(dataLayer.getLaunchCountCache().getLaunchCount() == 12)
    }

    @available(iOS 17.4, *)
    @Test
    @MainActor func launchCountChangedPublisherPublishesStoredLaunchCounts() async throws {

        let cache = try getCache()

        var cancellables: Set<AnyCancellable> = Set()
        var triggerCount: Int = 0
        var launchCountRef: Int = 0

        let expectedLaunchCount: Int = 7

        await withCheckedContinuation { continuation in

            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }

            cache
                .getLaunchCountChangedPublisher()
                .sink { (launchCount: Int) in

                    launchCountRef = launchCount

                    triggerCount += 1

                    guard launchCount == expectedLaunchCount else {
                        return
                    }

                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                }
                .store(in: &cancellables)

            Task {
                try await cache.storeLaunchCount(count: 1)
                try await cache.storeLaunchCount(count: 5)
                try await cache.storeLaunchCount(count: expectedLaunchCount)
            }
        }

        #expect(launchCountRef == expectedLaunchCount)
        #expect(triggerCount > 1)
    }
}

// MARK: - Test Helpers

extension LaunchCountCacheTests {

    @available(iOS 17.4, *)
    private func getCache() throws -> LaunchCountCache {

        return try getDataLayer().getLaunchCountCache()
    }

    @available(iOS 17.4, *)
    private func getDataLayer() throws -> AppDataLayerDependencies {

        let testsAppConfig = TestsAppConfig(
            swiftDatabase: try FakeSwiftDatabase.createSwiftDatabase()
        )

        let testsDiContainer = TestsDiContainer(testsAppConfig: testsAppConfig)

        return testsDiContainer.core.dataLayer
    }
}
