//
//  UserCountersCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import RepositorySync

struct UserCountersCacheTests {

    private static let sessionsCounterId: String = "sessions"
    private static let toolOpensCounterId: String = "tool_opens"

    struct GetCounterArgument {
        let cachedCount: Int?
        let localCount: Int?
        let expectedCount: Int
    }

    @available(iOS 17.4, *)
    @Test()
    func getCounterIsNilWhenNoLocalOrCachedCounterExists() async throws {

        let cache = try await getCache()

        let counter: UserCounterDataModel? = try cache.getCounter(id: Self.sessionsCounterId)

        #expect(counter == nil)
    }

    @available(iOS 17.4, *)
    @Test(arguments: [
        GetCounterArgument(cachedCount: 3, localCount: nil, expectedCount: 3),
        GetCounterArgument(cachedCount: nil, localCount: 2, expectedCount: 2),
        GetCounterArgument(cachedCount: 3, localCount: 2, expectedCount: 5)
    ])
    func getCounterReturnsSumOfLocalAndCachedCounts(argument: GetCounterArgument) async throws {

        let cachedCounters: [UserCounterCodable] = argument.cachedCount.map {
            [UserCounterCodable(id: Self.sessionsCounterId, count: $0)]
        } ?? []

        let localCounters: [LocalActivityCountDataModel] = argument.localCount.map {
            [LocalActivityCountDataModel(id: Self.sessionsCounterId, count: $0)]
        } ?? []

        let cache = try await getCache(
            cachedCounters: cachedCounters,
            localCounters: localCounters
        )

        let counter: UserCounterDataModel? = try cache.getCounter(id: Self.sessionsCounterId)

        #expect(counter?.id == Self.sessionsCounterId)
        #expect(counter?.count == argument.expectedCount)
    }

    @available(iOS 17.4, *)
    @Test()
    func mergeLocalCountersWithCachedCounters() async throws {

        let cache = try await getCache(
            cachedCounters: [
                UserCounterCodable(id: Self.sessionsCounterId, count: 3),
                UserCounterCodable(id: Self.toolOpensCounterId, count: 7)
            ],
            localCounters: [
                LocalActivityCountDataModel(id: Self.sessionsCounterId, count: 2)
            ]
        )

        let mergedCounters: [UserCounterDataModel] = try await cache.mergeLocalCountersWithCachedCounters()

        let sessionsCounter: UserCounterDataModel = try #require(mergedCounters.first(where: { $0.id == Self.sessionsCounterId }))
        let toolOpensCounter: UserCounterDataModel = try #require(mergedCounters.first(where: { $0.id == Self.toolOpensCounterId }))

        #expect(mergedCounters.count == 2)
        #expect(sessionsCounter.count == 5)
        #expect(toolOpensCounter.count == 7)
    }

    @available(iOS 17.4, *)
    @Test()
    func mergeLocalCountersWithProvidedCounters() async throws {

        let cache = try await getCache(
            localCounters: [
                LocalActivityCountDataModel(id: Self.sessionsCounterId, count: 4)
            ]
        )

        let counters: [UserCounterDataModel] = [
            UserCounterDataModel(id: Self.sessionsCounterId, count: 10),
            UserCounterDataModel(id: Self.toolOpensCounterId, count: 6)
        ]

        let mergedCounters: [UserCounterDataModel] = try cache.mergeLocalCountersWithCounters(counters: counters)

        let sessionsCounter: UserCounterDataModel = try #require(mergedCounters.first(where: { $0.id == Self.sessionsCounterId }))
        let toolOpensCounter: UserCounterDataModel = try #require(mergedCounters.first(where: { $0.id == Self.toolOpensCounterId }))

        #expect(mergedCounters.count == 2)
        #expect(sessionsCounter.count == 14)
        #expect(toolOpensCounter.count == 6)
    }

    @available(iOS 17.4, *)
    @Test()
    func deleteCountersRemovesCachedCountersAndKeepsLocalCounters() async throws {

        let cache = try await getCache(
            cachedCounters: [
                UserCounterCodable(id: Self.sessionsCounterId, count: 3),
                UserCounterCodable(id: Self.toolOpensCounterId, count: 7)
            ],
            localCounters: [
                LocalActivityCountDataModel(id: Self.sessionsCounterId, count: 2)
            ]
        )

        try await cache.deleteCounters()

        let cachedCountersCount: Int = try cache.persistence.getObjectCount()
        let sessionsCounter: UserCounterDataModel? = try cache.getCounter(id: Self.sessionsCounterId)
        let toolOpensCounter: UserCounterDataModel? = try cache.getCounter(id: Self.toolOpensCounterId)

        #expect(cachedCountersCount == 0)
        #expect(sessionsCounter?.count == 2)
        #expect(toolOpensCounter == nil)
    }
}

// MARK: - Test Helpers

extension UserCountersCacheTests {

    @available(iOS 17.4, *)
    private func getCache(cachedCounters: [UserCounterCodable] = [], localCounters: [LocalActivityCountDataModel] = []) async throws -> UserCountersCache {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let localActivityCounterPersistence = SwiftRepositorySyncPersistence(
            database: swiftDatabase,
            mapping: SwiftLocalActivityCountMapping()
        )

        let userCountersPersistence = SwiftRepositorySyncPersistence(
            database: swiftDatabase,
            mapping: SwiftUserCounterMapping()
        )

        _ = try await userCountersPersistence.writeObjects(externalObjects: cachedCounters)
        _ = try await localActivityCounterPersistence.writeObjects(externalObjects: localCounters)

        return UserCountersCache(
            localActivityCounterCache: LocalActivityCounterCache(
                persistence: localActivityCounterPersistence
            ),
            persistence: userCountersPersistence
        )
    }
}
