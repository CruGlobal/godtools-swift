//
//  SyncInvalidatorTests.swift
//  godtools
//
//  Created by Levi Eggert on 6/2/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import XCTest
@testable import godtools
import RealmSwift
import Combine

class SyncInvalidatorTests: XCTestCase {
    
    private static let sharedCache: SharedUserDefaultsCache = SharedUserDefaultsCache()
    private static let sharedSyncInvalidatorId: String = "SyncInvalidatorTests.syncInvalidatorKey"
    private static let syncInvalidatorId_1: String = "SyncInvalidatorTests.syncInvalidatorKey.1"
    private static let syncInvalidatorId_2: String = "SyncInvalidatorTests.syncInvalidatorKey.2"
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        SyncInvalidator(
            id: Self.sharedSyncInvalidatorId,
            timeInterval: .days(day: 1),
            userDefaultsCache: Self.sharedCache
        )
        .resetSync()
        
        SyncInvalidator(
            id: Self.syncInvalidatorId_1,
            timeInterval: .days(day: 1),
            userDefaultsCache: Self.sharedCache
        )
        .resetSync()
        
        SyncInvalidator(
            id: Self.syncInvalidatorId_2,
            timeInterval: .days(day: 1),
            userDefaultsCache: Self.sharedCache
        )
        .resetSync()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private static func getSharedSyncInvalidator(timeInterval: SyncInvalidatorTimeInterval) -> SyncInvalidator {
        return SyncInvalidator(
            id: Self.sharedSyncInvalidatorId,
            timeInterval: timeInterval,
            userDefaultsCache: Self.sharedCache
        )
    }
    
    func testShouldSyncShouldBeAvailableOnFirstAttempt() {
        
        let syncInvalidator: SyncInvalidator = Self.getSharedSyncInvalidator(timeInterval: .minutes(minute: 60))
        
        XCTAssertTrue(syncInvalidator.shouldSync)
    }
    
    func testResettingSyncMakesNewSyncAvailable() {
        
        let syncInvalidator: SyncInvalidator = Self.getSharedSyncInvalidator(timeInterval: .minutes(minute: 60))
    
        syncInvalidator.didSync()
        
        XCTAssertFalse(syncInvalidator.shouldSync)
        
        syncInvalidator.resetSync()
        
        XCTAssertTrue(syncInvalidator.shouldSync)
    }
    
    func testShouldNotSyncPriorToElapsedMinutes() {
        
        let thirtyMinutesAgo: Date? = Calendar.current.date(
            byAdding: DateComponents(minute: 30 * -1),
            to: Date()
        )
        
        XCTAssertNotNil(thirtyMinutesAgo)
        
        let syncInvalidator: SyncInvalidator = Self.getSharedSyncInvalidator(
            timeInterval: .minutes(minute: 60)
        )
        
        syncInvalidator.didSync(lastSyncDate: thirtyMinutesAgo!)
        
        XCTAssertFalse(syncInvalidator.shouldSync)
    }
    
    func testShouldSyncOnElapsedMinutes() {
        
        let oneHourAndThirtyMinutesAgo: Date? = Calendar.current.date(
            byAdding: DateComponents(minute: 60 * -1),
            to: Date()
        )
        
        XCTAssertNotNil(oneHourAndThirtyMinutesAgo)
        
        let syncInvalidator: SyncInvalidator = Self.getSharedSyncInvalidator(
            timeInterval: .minutes(minute: 60)
        )
        
        syncInvalidator.didSync(lastSyncDate: oneHourAndThirtyMinutesAgo!)
        
        XCTAssertTrue(syncInvalidator.shouldSync)
    }
    
    func testShouldSyncAfterElapsedMinutes() {
        
        let oneHourAndThirtyMinutesAgo: Date? = Calendar.current.date(
            byAdding: DateComponents(minute: 90 * -1),
            to: Date()
        )
        
        XCTAssertNotNil(oneHourAndThirtyMinutesAgo)
        
        let syncInvalidator: SyncInvalidator = Self.getSharedSyncInvalidator(
            timeInterval: .minutes(minute: 60)
        )
        
        syncInvalidator.didSync(lastSyncDate: oneHourAndThirtyMinutesAgo!)
        
        XCTAssertTrue(syncInvalidator.shouldSync)
    }
    
    func testShouldNotSyncPriorToElapsedHours() {
        
        let twoHoursAgo: Date? = Calendar.current.date(
            byAdding: DateComponents(hour: 2 * -1),
            to: Date()
        )
        
        XCTAssertNotNil(twoHoursAgo)
        
        let syncInvalidator: SyncInvalidator = Self.getSharedSyncInvalidator(
            timeInterval: .hours(hour: 4)
        )
        
        syncInvalidator.didSync(lastSyncDate: twoHoursAgo!)
        
        XCTAssertFalse(syncInvalidator.shouldSync)
    }
    
    func testShouldSyncOnElapsedHours() {
        
        let fourHoursAgo: Date? = Calendar.current.date(
            byAdding: DateComponents(hour: 4 * -1),
            to: Date()
        )
        
        XCTAssertNotNil(fourHoursAgo)
        
        let syncInvalidator: SyncInvalidator = Self.getSharedSyncInvalidator(
            timeInterval: .hours(hour: 4)
        )
        
        syncInvalidator.didSync(lastSyncDate: fourHoursAgo!)
        
        XCTAssertTrue(syncInvalidator.shouldSync)
    }
    
    func testShouldSyncAfterElapsedHours() {
        
        let fiveHoursAgo: Date? = Calendar.current.date(
            byAdding: DateComponents(hour: 5 * -1),
            to: Date()
        )
        
        XCTAssertNotNil(fiveHoursAgo)
        
        let syncInvalidator: SyncInvalidator = Self.getSharedSyncInvalidator(
            timeInterval: .hours(hour: 4)
        )
        
        syncInvalidator.didSync(lastSyncDate: fiveHoursAgo!)
        
        XCTAssertTrue(syncInvalidator.shouldSync)
    }
    
    func testShouldNotSyncPriorToElapsedDays() {
        
        let twoDaysAgo: Date? = Calendar.current.date(
            byAdding: DateComponents(day: 2 * -1),
            to: Date()
        )
        
        XCTAssertNotNil(twoDaysAgo)
        
        let syncInvalidator: SyncInvalidator = Self.getSharedSyncInvalidator(
            timeInterval: .days(day: 5)
        )
        
        syncInvalidator.didSync(lastSyncDate: twoDaysAgo!)
        
        XCTAssertFalse(syncInvalidator.shouldSync)
    }
    
    func testShouldSyncOnElapsedDays() {
        
        let fiveDaysAgo: Date? = Calendar.current.date(
            byAdding: DateComponents(day: 5 * -1),
            to: Date()
        )
        
        XCTAssertNotNil(fiveDaysAgo)
        
        let syncInvalidator: SyncInvalidator = Self.getSharedSyncInvalidator(
            timeInterval: .days(day: 5)
        )
        
        syncInvalidator.didSync(lastSyncDate: fiveDaysAgo!)
        
        XCTAssertTrue(syncInvalidator.shouldSync)
    }
    
    func testShouldSyncAfterElapsedDays() {
        
        let sixDaysAgo: Date? = Calendar.current.date(
            byAdding: DateComponents(day: 6 * -1),
            to: Date()
        )
        
        XCTAssertNotNil(sixDaysAgo)
        
        let syncInvalidator: SyncInvalidator = Self.getSharedSyncInvalidator(
            timeInterval: .days(day: 5)
        )
        
        syncInvalidator.didSync(lastSyncDate: sixDaysAgo!)
        
        XCTAssertTrue(syncInvalidator.shouldSync)
    }
    
    func testSyncInvalidatorIdIsUnique() {
        
        let syncInvalidator_1 = SyncInvalidator(
            id: Self.syncInvalidatorId_1,
            timeInterval: .hours(hour: 4),
            userDefaultsCache: Self.sharedCache
        )
        
        let syncInvalidator_2 = SyncInvalidator(
            id: Self.syncInvalidatorId_2,
            timeInterval: .hours(hour: 4),
            userDefaultsCache: Self.sharedCache
        )
        
        let twoHoursAgo: Date? = Calendar.current.date(
            byAdding: DateComponents(hour: 2 * -1),
            to: Date()
        )
        
        XCTAssertNotNil(twoHoursAgo)
        
        syncInvalidator_1.didSync(lastSyncDate: twoHoursAgo!)
        
        XCTAssertFalse(syncInvalidator_1.shouldSync)
        
        XCTAssertTrue(syncInvalidator_2.shouldSync)
    }
}
