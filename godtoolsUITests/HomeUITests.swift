//
//  HomeUITests.swift
//  godtoolsUITests
//
//  Created by Ryan Carlson on 4/16/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import XCTest

class HomeUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments.append("UI-Testing")
        app.launchArguments.append("UI-Testing-Skip-Onboarding")
        
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFindToolsButton() {
        
        let app = XCUIApplication()
        let godtoolsNavigationBar = app.navigationBars["GodTools"]
        godtoolsNavigationBar/*@START_MENU_TOKEN@*/.buttons["Find Tools"]/*[[".staticTexts[\"GodTools\"].buttons[\"Find Tools\"]",".buttons[\"Find Tools\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let table = app.tables[GTAccessibilityConstants.AddTools.tableView]
        debugPrint(table.cells.count)
        XCTAssert(table.cells.count == 4)
    }
    
    func testMyToolsButton() {
        let app = XCUIApplication()
        let godtoolsNavigationBar = app.navigationBars["GodTools"]
        
        godtoolsNavigationBar/*@START_MENU_TOKEN@*/.buttons["Find Tools"]/*[[".staticTexts[\"GodTools\"].buttons[\"Find Tools\"]",".buttons[\"Find Tools\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        godtoolsNavigationBar/*@START_MENU_TOKEN@*/.buttons["My Tools"]/*[[".staticTexts[\"GodTools\"].buttons[\"My Tools\"]",".buttons[\"My Tools\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let table = app.tables[GTAccessibilityConstants.Home.homeTableView]
        
        XCTAssert(table.cells.count == 3)
    }
}
