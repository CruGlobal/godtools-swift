//
//  LocalUserCounterIncrementTests.swift
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
struct LocalUserCounterIncrementTests {
        
    private let sessionsCounterId: String = "sessions"
    private let toolOpensCounterId: String = "tool_opens"
    
    @Test()
    func initialCountShouldBe1() async throws {
        
        let localCounterIncrement: LocalUserCounterIncrement = try getLocalUserCounterIncrement()
        
        let counterId: String = toolOpensCounterId
        
        #expect(try localCounterIncrement.getCounter(id: counterId) == nil)
        
        let updateCounter_1: LocalUserCounter = try localCounterIncrement.incrementCounter(id: counterId)
        let updateCounter_2: LocalUserCounter = try localCounterIncrement.incrementCounter(id: counterId)
        let updateCounter_3: LocalUserCounter = try localCounterIncrement.incrementCounter(id: counterId)
        
        #expect(updateCounter_1.localCount == 1)
        
        #expect(updateCounter_2.localCount == 2)
        
        #expect(updateCounter_3.localCount == 3)
    }
    
    @Test()
    func getCountersReturnsAllCounters() async throws {
        
        let localCounterIncrement: LocalUserCounterIncrement = try getLocalUserCounterIncrement()
                
        #expect(try localCounterIncrement.getCounter(id: sessionsCounterId) == nil)
        #expect(try localCounterIncrement.getCounter(id: toolOpensCounterId) == nil)
        #expect(try await localCounterIncrement.getCounters().count == 0)
        
        let sessionCounter: LocalUserCounter = try localCounterIncrement.incrementCounter(id: sessionsCounterId)
        
        _ = try localCounterIncrement.incrementCounter(id: toolOpensCounterId)
        let toolOpensCounter: LocalUserCounter = try localCounterIncrement.incrementCounter(id: toolOpensCounterId)
        
        #expect(sessionCounter.localCount == 1)
        
        #expect(toolOpensCounter.localCount == 2)
        
        let counters: [LocalUserCounter] = try localCounterIncrement.getCounters()
        let counterIds: [String] = counters.map { $0.id }.sorted()
        
        #expect(counterIds == [sessionsCounterId, toolOpensCounterId])
    }
    
    @Test()
    func decrementCounters() async throws {
        
        let localCounterIncrement: LocalUserCounterIncrement = try getLocalUserCounterIncrement()
        
        #expect(try localCounterIncrement.getCounter(id: sessionsCounterId) == nil)
        #expect(try localCounterIncrement.getCounter(id: toolOpensCounterId) == nil)
        #expect(try await localCounterIncrement.getCounters().count == 0)
        
        _ = try localCounterIncrement.incrementCounter(id: sessionsCounterId)
        _ = try localCounterIncrement.incrementCounter(id: sessionsCounterId)
        
        _ = try localCounterIncrement.incrementCounter(id: toolOpensCounterId)
        _ = try localCounterIncrement.incrementCounter(id: toolOpensCounterId)
        _ = try localCounterIncrement.incrementCounter(id: toolOpensCounterId)
        _ = try localCounterIncrement.incrementCounter(id: toolOpensCounterId)
        
        #expect(try localCounterIncrement.getCounter(id: sessionsCounterId)?.localCount == 2)
        
        #expect(try localCounterIncrement.getCounter(id: toolOpensCounterId)?.localCount == 4)
        
        try localCounterIncrement.decrementCount(id: sessionsCounterId, decrementBy: 3)
        
        try localCounterIncrement.decrementCount(id: toolOpensCounterId, decrementBy: 2)
        
        #expect(try localCounterIncrement.getCounter(id: sessionsCounterId)?.localCount == 0)
        
        #expect(try localCounterIncrement.getCounter(id: toolOpensCounterId)?.localCount == 2)
    }
}

extension LocalUserCounterIncrementTests {
    
    private func getLocalUserCounterIncrement() throws -> LocalUserCounterIncrement {
        
        let testsDiContainer = try TestsDiContainer(realmFileName: String(describing: LocalUserCounterIncrementTests.self))
        
        let realmPersistence = RealmRepositorySyncPersistence<UserCounterDataModel, UserCounterCodable, RealmUserCounter>(
            database: testsDiContainer.dataLayer.getSharedRealmDatabase(),
            dataModelMapping: RealmUserCounterMapping()
        )
        
        return LocalUserCounterIncrement(persistence: realmPersistence)
    }
}
