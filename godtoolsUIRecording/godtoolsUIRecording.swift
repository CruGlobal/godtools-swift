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
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testScreenShots() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
                
        
        let app = XCUIApplication()
        app.navigationBars["GodTools"].buttons["language logo white"].waitForExistence(timeout: 10)
        snapshot("01MyTools")
        
        app.navigationBars["GodTools"].buttons["language logo white"].tap()
        app.buttons["Select a Parallel Language"].tap()
        app.navigationBars["Parallel Language"].buttons["Back"].waitForExistence(timeout: 5)
        snapshot("02ParallelLanguages")
        
        app.navigationBars["Parallel Language"].buttons["Back"].tap()
        app.navigationBars["Language Settings"].buttons["Back"].tap()
        XCUIApplication()/*@START_MENU_TOKEN@*/.tables["home_table_view"].cells.containing(.staticText, identifier:"Knowing God Personally")/*[[".otherElements[\"home_my_tools_view\"].tables[\"home_table_view\"]",".cells.containing(.staticText, identifier:\"Uses hand drawn images to illustrate God's invitation to know Him personally.\")",".cells.containing(.staticText, identifier:\"Knowing God Personally\")",".tables[\"home_table_view\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.otherElements["Progress"].waitForExistence(timeout: 5)
        XCUIApplication()/*@START_MENU_TOKEN@*/.tables["home_table_view"].cells.containing(.staticText, identifier:"Knowing God Personally")/*[[".otherElements[\"home_my_tools_view\"].tables[\"home_table_view\"]",".cells.containing(.staticText, identifier:\"Uses hand drawn images to illustrate God's invitation to know Him personally.\")",".cells.containing(.staticText, identifier:\"Knowing God Personally\")",".tables[\"home_table_view\"]"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.otherElements["Progress"].tap()
        app.otherElements.containing(.navigationBar, identifier:"GodTools").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).buttons["right arrow blue"].tap()
        snapshot("03KnowingGod")
        
        app.navigationBars["GodTools"].buttons["home"].tap()
        sleep(5)
        if !XCUIApplication().tables["home_table_view"].cells.containing(.staticText, identifier:"Know God Personally").otherElements["Progress"].waitForExistence(timeout: 5)
        {
            app.navigationBars["GodTools"]/*@START_MENU_TOKEN@*/.buttons["Find Tools"]/*[[".segmentedControls[\"GodTools\"].buttons[\"Find Tools\"]",".buttons[\"Find Tools\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            app.tables/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"Know God Personally")/*[[".cells.containing(.staticText, identifier:\"Explains how to begin a personal relationship with God.\")",".cells.containing(.staticText, identifier:\"Know God Personally\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["download green"].tap()
            app.navigationBars["GodTools"]/*@START_MENU_TOKEN@*/.buttons["My Tools"]/*[[".segmentedControls[\"GodTools\"].buttons[\"My Tools\"]",".buttons[\"My Tools\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            sleep(5)
        }
        XCUIApplication().tables["home_table_view"].cells.containing(.staticText, identifier:"Know God Personally").otherElements["Progress"].waitForExistence(timeout: 5)
        XCUIApplication().tables["home_table_view"].cells.containing(.staticText, identifier:"Know God Personally").otherElements["Progress"].tap()
        app.otherElements.containing(.navigationBar, identifier:"GodTools").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).buttons["right arrow blue"].tap()
        snapshot("04KnowGodPersonally")

        XCUIApplication().navigationBars["GodTools"].buttons["home"].tap()
        sleep(5)

        XCUIApplication().tables["home_table_view"].cells.containing(.staticText, identifier:"Four Spiritual Laws").otherElements["Progress"].waitForExistence(timeout: 5)
        XCUIApplication().tables["home_table_view"].cells.containing(.staticText, identifier:"Four Spiritual Laws").otherElements["Progress"].tap()
        XCUIApplication().otherElements.containing(.navigationBar, identifier:"GodTools").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).buttons["right arrow blue"].tap()
        snapshot("05FourSpiritualLaws")

        XCUIApplication().navigationBars["GodTools"].buttons["home"].tap()
        sleep(5)
        if !XCUIApplication().tables["home_table_view"].cells.containing(.staticText, identifier:"Satisfied?").otherElements["Progress"].waitForExistence(timeout: 5)
        {
            app.navigationBars["GodTools"]/*@START_MENU_TOKEN@*/.buttons["Find Tools"]/*[[".segmentedControls[\"GodTools\"].buttons[\"Find Tools\"]",".buttons[\"Find Tools\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            app.tables/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"Know God Personally")/*[[".cells.containing(.staticText, identifier:\"Explains how to begin a personal relationship with God.\")",".cells.containing(.staticText, identifier:\"Know God Personally\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["download green"].tap()
            app.navigationBars["GodTools"]/*@START_MENU_TOKEN@*/.buttons["My Tools"]/*[[".segmentedControls[\"GodTools\"].buttons[\"My Tools\"]",".buttons[\"My Tools\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            sleep(5)
        }
        XCUIApplication().tables["home_table_view"].cells.containing(.staticText, identifier:"Satisfied?").otherElements["Progress"].waitForExistence(timeout: 5)
        XCUIApplication().tables["home_table_view"].cells.containing(.staticText, identifier:"Satisfied?").otherElements["Progress"].tap()
        app.otherElements.containing(.navigationBar, identifier:"GodTools").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).buttons["right arrow blue"].tap()
        snapshot("06Satisfied")

        XCUIApplication().navigationBars["GodTools"].buttons["home"].tap()
        sleep(5)
        if !XCUIApplication().tables["home_table_view"].cells.containing(.staticText, identifier:"THE FOUR").otherElements["Progress"].waitForExistence(timeout: 5)
        {
            app.navigationBars["GodTools"]/*@START_MENU_TOKEN@*/.buttons["Find Tools"]/*[[".segmentedControls[\"GodTools\"].buttons[\"Find Tools\"]",".buttons[\"Find Tools\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            app.tables.cells.containing(.staticText, identifier:"THE FOUR").buttons["download green"].tap()
            app.navigationBars["GodTools"]/*@START_MENU_TOKEN@*/.buttons["My Tools"]/*[[".segmentedControls[\"GodTools\"].buttons[\"My Tools\"]",".buttons[\"My Tools\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            sleep(10)
        }

        XCUIApplication().tables["home_table_view"].cells.containing(.staticText, identifier:"THE FOUR").otherElements["Progress"].waitForExistence(timeout: 5)
        XCUIApplication().tables["home_table_view"].cells.containing(.staticText, identifier:"THE FOUR").otherElements["Progress"].tap()
        let element = XCUIApplication().otherElements.containing(.navigationBar, identifier:"GodTools").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 1).swipeLeft()
        
        let element2 = element.children(matching: .other).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element(boundBy: 1)
        element2.swipeLeft()
        element2.swipeLeft()
        snapshot("07TheFour")
        
        XCUIApplication().navigationBars["GodTools"].buttons["home"].tap()
        sleep(5)
        if !XCUIApplication().tables["home_table_view"].cells.containing(.staticText, identifier:"Honor Restored").otherElements["Progress"].waitForExistence(timeout: 5)
        {
            app.navigationBars["GodTools"]/*@START_MENU_TOKEN@*/.buttons["Find Tools"]/*[[".segmentedControls[\"GodTools\"].buttons[\"Find Tools\"]",".buttons[\"Find Tools\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            app.tables.cells.containing(.staticText, identifier:"Honor Restored").buttons["download green"].tap()
            app.navigationBars["GodTools"]/*@START_MENU_TOKEN@*/.buttons["My Tools"]/*[[".segmentedControls[\"GodTools\"].buttons[\"My Tools\"]",".buttons[\"My Tools\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            sleep(10)
        }
        XCUIApplication().tables["home_table_view"].cells.containing(.staticText, identifier:"Honor Restored").otherElements["Progress"].waitForExistence(timeout: 5)
        XCUIApplication().tables["home_table_view"].cells.containing(.staticText, identifier:"Honor Restored").otherElements["Progress"].tap()
        snapshot("08HonorRestored")
        
        XCUIApplication().navigationBars["GodTools"].buttons["home"].tap()
        sleep(5)
        XCUIApplication().tables["home_table_view"].cells.containing(.staticText, identifier:"Teach Me to Share").otherElements["Progress"].waitForExistence(timeout: 5)
        XCUIApplication().tables["home_table_view"].cells.containing(.staticText, identifier:"Teach Me to Share").otherElements["Progress"].tap()
        snapshot("09TeachMeToShare")

    }
}
