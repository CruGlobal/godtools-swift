//
//  LocalActivityCounterCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 3/4/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import RepositorySync

@Suite(.serialized)
struct LocalActivityCounterCacheTests {
        
    private let sessionsCounterId: String = "sessions"
    private let toolOpensCounterId: String = "tool_opens"
    
    @Test()
    func initialCountShouldBe1() async throws {
        
        let cache: LocalActivityCounterCache = try getLocalActivityCounterCache()
        
        let counterId: String = toolOpensCounterId
        
        #expect(try cache.getCounter(id: counterId) == nil)
        
        let updateCounter_1: LocalActivityCountDataModel = try cache.incrementCounter(id: counterId)
        let updateCounter_2: LocalActivityCountDataModel = try cache.incrementCounter(id: counterId)
        let updateCounter_3: LocalActivityCountDataModel = try cache.incrementCounter(id: counterId)
        
        #expect(updateCounter_1.count == 1)
        
        #expect(updateCounter_2.count == 2)
        
        #expect(updateCounter_3.count == 3)
    }
    
    @Test()
    func getCountersReturnsAllCounters() async throws {
        
        let cache: LocalActivityCounterCache = try getLocalActivityCounterCache()
                
        #expect(try cache.getCounter(id: sessionsCounterId) == nil)
        #expect(try cache.getCounter(id: toolOpensCounterId) == nil)
        #expect(try await cache.getCounters().count == 0)
        
        let sessionCounter: LocalActivityCountDataModel = try cache.incrementCounter(id: sessionsCounterId)
        
        _ = try cache.incrementCounter(id: toolOpensCounterId)
        let toolOpensCounter: LocalActivityCountDataModel = try cache.incrementCounter(id: toolOpensCounterId)
        
        #expect(sessionCounter.count == 1)
        
        #expect(toolOpensCounter.count == 2)
        
        let counters: [LocalActivityCountDataModel] = try await cache.getCounters()
        let counterIds: [String] = counters.map { $0.id }.sorted()
        
        #expect(counterIds == [sessionsCounterId, toolOpensCounterId])
    }
    
    @Test()
    func decrementCounters() async throws {
        
        let cache: LocalActivityCounterCache = try getLocalActivityCounterCache()
        
        #expect(try cache.getCounter(id: sessionsCounterId) == nil)
        #expect(try cache.getCounter(id: toolOpensCounterId) == nil)
        #expect(try await cache.getCounters().count == 0)
        
        _ = try cache.incrementCounter(id: sessionsCounterId)
        _ = try cache.incrementCounter(id: sessionsCounterId)
        
        _ = try cache.incrementCounter(id: toolOpensCounterId)
        _ = try cache.incrementCounter(id: toolOpensCounterId)
        _ = try cache.incrementCounter(id: toolOpensCounterId)
        _ = try cache.incrementCounter(id: toolOpensCounterId)
        
        #expect(try cache.getCounter(id: sessionsCounterId)?.count == 2)
        
        #expect(try cache.getCounter(id: toolOpensCounterId)?.count == 4)
        
        try cache.decrementCount(id: sessionsCounterId, decrementBy: 3)
        
        try cache.decrementCount(id: toolOpensCounterId, decrementBy: 2)
        
        #expect(try cache.getCounter(id: sessionsCounterId)?.count == 0)
        
        #expect(try cache.getCounter(id: toolOpensCounterId)?.count == 2)
    }
}

extension LocalActivityCounterCacheTests {
    
    private func getLocalActivityCounterCache() throws -> LocalActivityCounterCache {
        
        let testsDiContainer = try TestsDiContainer(realmFileName: String(describing: LocalActivityCounterCacheTests.self))
        
        let realmPersistence = RealmRepositorySyncPersistence<LocalActivityCountDataModel, LocalActivityCountDataModel, RealmLocalActivityCount>(
            database: testsDiContainer.core.dataLayer.getSharedRealmDatabase(),
            dataModelMapping: RealmLocalActivityCountMapping()
        )
        
        return LocalActivityCounterCache(
            persistence: realmPersistence
        )
    }
}
