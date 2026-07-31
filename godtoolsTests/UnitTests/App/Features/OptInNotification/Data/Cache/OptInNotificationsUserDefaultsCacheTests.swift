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

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()

    private let cache: OptInNotificationUserDefaultsCache = OptInNotificationUserDefaultsCache(userDefaultsCache: SharedUserDefaultsCache())

    override func setUp() async throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        await cache.deleteAllData()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFirstRecordPromptValuesAreCorrect() async {

        await cache.recordPrompt()

        let todaysDate: Date = Date()
        let todaysStringDate: String = Self.dateFormatter.string(from: todaysDate)

        let lastPromptedStringDate: String?

        if let lastPromptedDate = await cache.getLastPrompted() {
            lastPromptedStringDate = Self.dateFormatter.string(from: lastPromptedDate)
        }
        else {
            lastPromptedStringDate = nil
        }

        let promptCount: Int = await cache.getPromptCount()

        XCTAssertTrue(promptCount == 1)
        XCTAssertTrue(todaysStringDate == lastPromptedStringDate)
    }

    func testSecondRecordPromptCountIsCorrect() async {

        await cache.recordPrompt()
        await cache.recordPrompt()

        let promptCount: Int = await cache.getPromptCount()

        XCTAssertTrue(promptCount == 2)
    }

    func testAllDataIsDeleted() async {

        await cache.recordPrompt()

        let promptCountAfterRecordingPrompt: Int = await cache.getPromptCount()
        let lastPromptedAfterRecordingPrompt: Date? = await cache.getLastPrompted()

        XCTAssertNotNil(promptCountAfterRecordingPrompt)
        XCTAssertNotNil(lastPromptedAfterRecordingPrompt)

        await cache.deleteAllData()

        let promptCountAfterDeletingAllData: Int = await cache.getPromptCount()
        let lastPromptedAfterDeletingAllData: Date? = await cache.getLastPrompted()

        XCTAssertTrue(promptCountAfterDeletingAllData == 0)
        XCTAssertNil(lastPromptedAfterDeletingAllData)
    }
}
