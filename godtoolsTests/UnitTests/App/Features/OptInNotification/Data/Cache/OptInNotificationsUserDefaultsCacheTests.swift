//
//  OptInNotificationUserDefaultsCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 4/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import XCTest
@testable import godtools

class OptInNotificationUserDefaultsCacheTests: XCTestCase {
    
    private let cache: OptInNotificationUserDefaultsCache = OptInNotificationUserDefaultsCache(sharedUserDefaultsCache: SharedUserDefaultsCache())
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cache.deleteAllData()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFirstRecordPromptValuesAreCorrect() {
        
        cache.recordPrompt()
        
        let todaysDate: Date = Date()
        let todaysStringDate: String = OptInNotificationUserDefaultsCache.dateFormatter.string(from: todaysDate)
        
        let lastPromptedStringDate: String?
        
        if let lastPromptedDate = cache.getLastPrompted() {
            lastPromptedStringDate = OptInNotificationUserDefaultsCache.dateFormatter.string(from: lastPromptedDate)
        }
        else {
            lastPromptedStringDate = nil
        }
        
        XCTAssertTrue(cache.getPromptCount() == 1)
        XCTAssertTrue(todaysStringDate == lastPromptedStringDate)
    }
    
    func testSecondRecordPromptCountIsCorrect() {
        
        cache.recordPrompt()
        cache.recordPrompt()

        XCTAssertTrue(cache.getPromptCount() == 2)
    }
    
    func testAllDataIsDeleted() {
        
        cache.recordPrompt()
        
        XCTAssertNotNil(cache.getPromptCount())
        XCTAssertNotNil(cache.getLastPrompted())
        
        cache.deleteAllData()
        
        XCTAssertTrue(cache.getPromptCount() == 0)
        XCTAssertNil(cache.getLastPrompted())
    }
}
