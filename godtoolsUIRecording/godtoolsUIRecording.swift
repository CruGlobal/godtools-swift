//
//  godtoolsUIRecording.swift
//  godtoolsUIRecording
//
//  Created by Dean Thibault on 8/16/19.
//  Copyright © 2019 Cru. All rights reserved.
//

import XCTest

class godtoolsUIRecording: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        addUIInterruptionMonitor(withDescription: "System Dialog") {
            (alert) -> Bool in
            let button = alert.buttons.element(boundBy: 1)
            if button.exists {
                button.tap()
            }
            return true
        }

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testScreenShots() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
                
        
        let app = XCUIApplication()
        _ = app.navigationBars["GodTools"].buttons["language logo white"].waitForExistence(timeout: 10)
        
        app.navigationBars["GodTools"].buttons["language logo white"].tap()
        app.buttons["select_parallel_language"].tap()
        _ = app.navigationBars["parallel_language"].buttons["Back"].waitForExistence(timeout: 5)
        snapshot("02ParallelLanguages")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        sleep(20) // allow translations to download before continuing
        
        snapshot("01MyTools")

        let toolsTable = app.tables["home_table_view"]
        var cell = toolsTable.cells.element(matching: .cell, identifier: "Knowing God Personally")
        _ = cell.otherElements["Progress"].waitForExistence(timeout: 5)
        tapAndHandleDownloadAlert(element: cell.otherElements["Progress"])
        app.otherElements.containing(.navigationBar, identifier:"GodTools").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).buttons["right arrow blue"].tap()
        snapshot("03KnowingGod")
        
        app.navigationBars["GodTools"].buttons["home"].tap()
        sleep(5)
        cell = toolsTable.cells.element(matching: .cell, identifier: "Know God Personally")
        if !cell.otherElements["Progress"].waitForExistence(timeout: 5)
        {
            let button = app.navigationBars["GodTools"].buttons.element(matching: .button, identifier: "find_tools")
            button.tap()
            app.tables.cells.element(matching: .cell, identifier: "Know God Personally").buttons["download green"].tap()
            app.navigationBars["GodTools"].buttons.element(matching: .button, identifier: "my_tools").tap()
            sleep(5)
        }
        _ = cell.otherElements["Progress"].waitForExistence(timeout: 5)
        tapAndHandleDownloadAlert(element: cell.otherElements["Progress"])
        app.otherElements.containing(.navigationBar, identifier:"GodTools").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).buttons["right arrow blue"].tap()
        snapshot("04KnowGodPersonally")

        XCUIApplication().navigationBars["GodTools"].buttons["home"].tap()
        sleep(5)

        cell = toolsTable.cells.element(matching: .cell, identifier: "Four Spiritual Laws")
        _ = cell.otherElements["Progress"].waitForExistence(timeout: 5)
        tapAndHandleDownloadAlert(element: cell.otherElements["Progress"])
        XCUIApplication().otherElements.containing(.navigationBar, identifier:"GodTools").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).buttons["right arrow blue"].tap()
        snapshot("05FourSpiritualLaws")

        XCUIApplication().navigationBars["GodTools"].buttons["home"].tap()
        sleep(5)
        cell = toolsTable.cells.element(matching: .cell, identifier: "Satisfied?")
        if !cell.otherElements["Progress"].waitForExistence(timeout: 5)
        {
            let button = app.navigationBars["GodTools"].buttons.element(matching: .button, identifier: "find_tools")
            button.tap()
            app.tables.cells.element(matching: .cell, identifier: "Satisfied?").buttons["download green"].tap()
            app.navigationBars["GodTools"].buttons.element(matching: .button, identifier: "my_tools").tap()
            sleep(5)
        }
        _ = cell.otherElements["Progress"].waitForExistence(timeout: 5)
        tapAndHandleDownloadAlert(element: cell.otherElements["Progress"])
        app.otherElements.containing(.navigationBar, identifier:"GodTools").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).buttons["right arrow blue"].tap()
        snapshot("06Satisfied")

        XCUIApplication().navigationBars["GodTools"].buttons["home"].tap()
        sleep(5)
        if !app.tables.cells.element(matching: .cell, identifier: "The FOUR").otherElements["Progress"].waitForExistence(timeout: 5)
        {
            let button = app.navigationBars["GodTools"].buttons.element(matching: .button, identifier: "find_tools")
            button.tap()
            app.tables.cells.element(matching: .cell, identifier: "The FOUR").buttons["download green"].tap()
            app.navigationBars["GodTools"].buttons.element(matching: .button, identifier: "my_tools").tap()
            sleep(10)
        }

        _ = toolsTable.cells.element(matching: .cell, identifier: "The FOUR").waitForExistence(timeout: 5)
        cell = toolsTable.cells.element(matching: .cell, identifier: "The FOUR")
        _ = cell.otherElements["Progress"].waitForExistence(timeout: 5)
        scrollToCell(with: "The FOUR")
        tapAndHandleDownloadAlert(element: cell.otherElements["Progress"])
        sleep(5)
        let element = XCUIApplication().otherElements.containing(.navigationBar, identifier:"GodTools").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 1).swipeLeft()
        
        let element2 = element.children(matching: .other).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element(boundBy: 1)
        element2.swipeLeft()
        element2.swipeLeft()
        snapshot("07TheFour")
        
        XCUIApplication().navigationBars["GodTools"].buttons["home"].tap()
        sleep(5)
        cell = toolsTable.cells.element(matching: .cell, identifier: "Honor Restored")
        if !cell.otherElements["Progress"].waitForExistence(timeout: 5)
        {
            let button = app.navigationBars["GodTools"].buttons.element(matching: .button, identifier: "find_tools")
            button.tap()
            app.tables.cells.element(matching: .cell, identifier: "Honor Restored").buttons["download green"].tap()
            app.navigationBars["GodTools"].buttons.element(matching: .button, identifier: "my_tools").tap()
            sleep(10)
        }
        _ = cell.otherElements["Progress"].waitForExistence(timeout: 5)
        tapAndHandleDownloadAlert(element: cell.otherElements["Progress"])
        snapshot("08HonorRestored")
        
        XCUIApplication().navigationBars["GodTools"].buttons["home"].tap()
        sleep(5)
        cell = toolsTable.cells.element(matching: .cell, identifier: "Teach Me to Share")
        _ = cell.otherElements["Progress"].waitForExistence(timeout: 5)
        tapAndHandleDownloadAlert(element: cell.otherElements["Progress"])
        snapshot("09TeachMeToShare")

    }
    
    func localized(_ key: String) -> String {
        let uiTestBundle = Bundle(for: godtoolsUIRecording.self)
        return localizationServices.stringForMainBundle(key: key, bundle: uiTestBundle)
    }
    
    func scrollToCell(with identifer: String) {
        let toolsTable =  XCUIApplication().tables["home_table_view"]

        guard XCUIApplication().tables.cells.element(matching: .cell, identifier: identifer).exists else { return }
        
        let cell = XCUIApplication().tables.cells.element(matching: .cell, identifier: identifer)
        while  !cell.isHittable {
           toolsTable.swipeUp()
        }
    }
    
    func tapAndHandleDownloadAlert(element: XCUIElement, waitTime: UInt32 = 20, timeout: TimeInterval = 60) {
        let time = Date()
        
        element.tap()
        
        if !XCUIApplication().alerts.element.waitForExistence(timeout: 5) {
            return // there's no alert to dismiss
        }
        
        // Continue checking for alert until tool is downloaded
        while XCUIApplication().alerts.element.waitForExistence(timeout: 5) {
            if XCUIApplication().alerts.element.buttons.element(matching: .button, identifier: "download_in_progress_ok").waitForExistence(timeout: 5) {
                XCUIApplication().alerts.element.buttons.element(matching: .button, identifier: "download_in_progress_ok").tap()
                
                if time.timeIntervalSinceNow < -timeout {
                    XCTFail("Timedout waiting for download to complete")
                }
                
                sleep(waitTime) // allow download to complete before continuing
                element.tap()
            }
        }
    }
}
