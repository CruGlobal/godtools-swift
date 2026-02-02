//
//  SyncInvalidatorTests.swift
//  godtools
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools

struct SyncInvalidatorTests {
        
    @Test()
    func shouldSyncShouldBeAvailableOnFirstAttempt() async {
        
        let syncInvalidator: SyncInvalidator = getSyncInvalidator(timeInterval: .minutes(minute: 60))
                
        #expect(syncInvalidator.shouldSync == true)
    }
    
    @Test()
    func resettingSyncMakesNewSyncAvailable() async {
        
        let syncInvalidator: SyncInvalidator = getSyncInvalidator(timeInterval: .minutes(minute: 60))
    
        syncInvalidator.didSync()
        
        #expect(syncInvalidator.shouldSync == false)
        
        syncInvalidator.resetSync()
        
        #expect(syncInvalidator.shouldSync == true)
    }
    
    @Test()
    func shouldNotSyncPriorToElapsedMinutes() async throws {
        
        let thirtyMinutesAgo: Date = try #require(Calendar.current.date(
            byAdding: DateComponents(minute: 30 * -1),
            to: Date()
        ))
                
        let syncInvalidator: SyncInvalidator = getSyncInvalidator(timeInterval: .minutes(minute: 60))
        
        syncInvalidator.didSync(lastSyncDate: thirtyMinutesAgo)
        
        #expect(syncInvalidator.shouldSync == false)
    }
    
    @Test()
    func shouldSyncOnElapsedMinutes() async throws {
        
        let oneHourAndThirtyMinutesAgo: Date = try #require(Calendar.current.date(
            byAdding: DateComponents(minute: 60 * -1),
            to: Date()
        ))
                
        let syncInvalidator: SyncInvalidator = getSyncInvalidator(timeInterval: .minutes(minute: 60))
        
        syncInvalidator.didSync(lastSyncDate: oneHourAndThirtyMinutesAgo)
        
        #expect(syncInvalidator.shouldSync == true)
    }
    
    @Test()
    func shouldSyncAfterElapsedMinutes() async throws {
        
        let oneHourAndThirtyMinutesAgo: Date = try #require(Calendar.current.date(
            byAdding: DateComponents(minute: 90 * -1),
            to: Date()
        ))
                
        let syncInvalidator: SyncInvalidator = getSyncInvalidator(timeInterval: .minutes(minute: 60))
        
        syncInvalidator.didSync(lastSyncDate: oneHourAndThirtyMinutesAgo)
        
        #expect(syncInvalidator.shouldSync == true)
    }
    
    @Test()
    func shouldNotSyncPriorToElapsedHours() async throws {
        
        let twoHoursAgo: Date = try #require(Calendar.current.date(
            byAdding: DateComponents(hour: 2 * -1),
            to: Date()
        ))
                
        let syncInvalidator: SyncInvalidator = getSyncInvalidator(timeInterval: .hours(hour: 4))
        
        syncInvalidator.didSync(lastSyncDate: twoHoursAgo)
        
        #expect(syncInvalidator.shouldSync == false)
    }
    
    @Test()
    func shouldSyncOnElapsedHours() async throws {
        
        let fourHoursAgo: Date = try #require(Calendar.current.date(
            byAdding: DateComponents(hour: 4 * -1),
            to: Date()
        ))
                
        let syncInvalidator: SyncInvalidator = getSyncInvalidator(timeInterval: .hours(hour: 4))
        
        syncInvalidator.didSync(lastSyncDate: fourHoursAgo)
        
        #expect(syncInvalidator.shouldSync == true)
    }
    
    @Test()
    func shouldSyncAfterElapsedHours() async throws {
        
        let fiveHoursAgo: Date = try #require(Calendar.current.date(
            byAdding: DateComponents(hour: 5 * -1),
            to: Date()
        ))
                
        let syncInvalidator: SyncInvalidator = getSyncInvalidator(timeInterval: .hours(hour: 4))
        
        syncInvalidator.didSync(lastSyncDate: fiveHoursAgo)
        
        #expect(syncInvalidator.shouldSync == true)
    }
    
    @Test()
    func shouldNotSyncPriorToElapsedDays() async throws {
        
        let twoDaysAgo: Date = try #require(Calendar.current.date(
            byAdding: DateComponents(day: 2 * -1),
            to: Date()
        ))
                
        let syncInvalidator: SyncInvalidator = getSyncInvalidator(timeInterval: .days(day: 5))
        
        syncInvalidator.didSync(lastSyncDate: twoDaysAgo)
        
        #expect(syncInvalidator.shouldSync == false)
    }
    
    @Test()
    func shouldSyncOnElapsedDays() async throws {
        
        let fiveDaysAgo: Date = try #require(Calendar.current.date(
            byAdding: DateComponents(day: 5 * -1),
            to: Date()
        ))
                
        let syncInvalidator: SyncInvalidator = getSyncInvalidator(timeInterval: .days(day: 5))
        
        syncInvalidator.didSync(lastSyncDate: fiveDaysAgo)
        
        #expect(syncInvalidator.shouldSync == true)
    }
    
    @Test()
    func shouldSyncAfterElapsedDays() async throws {
        
        let sixDaysAgo: Date = try #require(Calendar.current.date(
            byAdding: DateComponents(day: 6 * -1),
            to: Date()
        ))
                
        let syncInvalidator: SyncInvalidator = getSyncInvalidator(timeInterval: .days(day: 5))
        
        syncInvalidator.didSync(lastSyncDate: sixDaysAgo)
        
        #expect(syncInvalidator.shouldSync == true)
    }
    
    @Test()
    func syncInvalidatorIdIsUnique() async throws {
        
        let persistence = MockSyncInvalidatorPersistence()
        
        let syncInvalidator_1: SyncInvalidator = getSyncInvalidator(
            timeInterval: .hours(hour: 4),
            persistence: persistence
        )
        
        let syncInvalidator_2: SyncInvalidator = getSyncInvalidator(
            timeInterval: .hours(hour: 4),
            persistence: persistence
        )
        
        let twoHoursAgo: Date = try #require(Calendar.current.date(
            byAdding: DateComponents(hour: 2 * -1),
            to: Date()
        ))
                
        syncInvalidator_1.didSync(lastSyncDate: twoHoursAgo)
        
        #expect(syncInvalidator_1.shouldSync == false)
        
        #expect(syncInvalidator_2.shouldSync == true)
    }
}

extension SyncInvalidatorTests {
    
    private func getSyncInvalidator(timeInterval: SyncInvalidatorTimeInterval, persistence: SyncInvalidatorPersistenceInterface = MockSyncInvalidatorPersistence()) -> SyncInvalidator {
        
        return SyncInvalidator(
            id: UUID().uuidString,
            timeInterval: timeInterval,
            persistence: persistence
        )
    }
}
