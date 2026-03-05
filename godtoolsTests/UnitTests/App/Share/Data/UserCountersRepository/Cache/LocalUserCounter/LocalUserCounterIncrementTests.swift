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
        
        let updateCounter_1: UserCounterDataModel = try await localCounterIncrement.incrementCounter(id: counterId)
        let updateCounter_2: UserCounterDataModel = try await localCounterIncrement.incrementCounter(id: counterId)
        let updateCounter_3: UserCounterDataModel = try await localCounterIncrement.incrementCounter(id: counterId)
        
        #expect(updateCounter_1.count == 1)
        #expect(updateCounter_1.localCount == 1)
        
        #expect(updateCounter_2.count == 2)
        #expect(updateCounter_2.localCount == 2)
        
        #expect(updateCounter_3.count == 3)
        #expect(updateCounter_3.localCount == 3)
    }
    
    @Test()
    func getCountersReturnsAllCounters() async throws {
        
        let localCounterIncrement: LocalUserCounterIncrement = try getLocalUserCounterIncrement()
                
        #expect(try localCounterIncrement.getCounter(id: sessionsCounterId) == nil)
        #expect(try localCounterIncrement.getCounter(id: toolOpensCounterId) == nil)
        #expect(try await localCounterIncrement.getCounters().count == 0)
        
        let sessionCounter: UserCounterDataModel = try await localCounterIncrement.incrementCounter(id: sessionsCounterId)
        
        _ = try await localCounterIncrement.incrementCounter(id: toolOpensCounterId)
        let toolOpensCounter: UserCounterDataModel = try await localCounterIncrement.incrementCounter(id: toolOpensCounterId)
        
        #expect(sessionCounter.count == 1)
        #expect(sessionCounter.localCount == 1)
        
        #expect(toolOpensCounter.count == 2)
        #expect(toolOpensCounter.localCount == 2)
        
        let counters: [UserCounterDataModel] = try await localCounterIncrement.getCounters()
        let counterIds: [String] = counters.map { $0.id }.sorted()
        
        #expect(counterIds == [sessionsCounterId, toolOpensCounterId])
    }
    
    @Test()
    func deleteCounters() async throws {
        
        let localCounterIncrement: LocalUserCounterIncrement = try getLocalUserCounterIncrement()
        
        #expect(try localCounterIncrement.getCounter(id: sessionsCounterId) == nil)
        #expect(try localCounterIncrement.getCounter(id: toolOpensCounterId) == nil)
        #expect(try await localCounterIncrement.getCounters().count == 0)
        
        _ = try await localCounterIncrement.incrementCounter(id: sessionsCounterId)
        _ = try await localCounterIncrement.incrementCounter(id: toolOpensCounterId)
        
        let counters: [UserCounterDataModel] = try await localCounterIncrement.getCounters()
        let counterIds: [String] = counters.map { $0.id }.sorted()
        
        #expect(counterIds == [sessionsCounterId, toolOpensCounterId])
        
        try await localCounterIncrement.deleteCounters()
        
        #expect(try await localCounterIncrement.getCounters().count == 0)
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
