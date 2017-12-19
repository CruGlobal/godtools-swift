//
//  godtoolsUITests.swift
//  godtoolsUITests
//
//  Created by Ryan Carlson on 12/18/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import XCTest

class godtoolsUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTakeScreenshots() {
        
        let app = XCUIApplication()
        if app.buttons["ok"].exists {
        app/*@START_MENU_TOKEN@*/.buttons["ok"]/*[[".buttons[\"Okay\"]",".buttons[\"ok\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
        
        if app.buttons["later"].exists {
        app/*@START_MENU_TOKEN@*/.buttons["later"]/*[[".buttons[\"Later\"]",".buttons[\"later\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
        
        snapshot("01_HomeScreen")
        
        app.navigationBars["navbar"].buttons["nav_languages"].tap()
        app/*@START_MENU_TOKEN@*/.buttons["languages_primary_btn"]/*[[".buttons[\"English\"]",".buttons[\"languages_primary_btn\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("02_LanguagesScreen")
        
        // back to language settings screen
        app.navigationBars["navbar"].buttons.element(boundBy: 0).tap()
        
        // go to select parallel language
        app.buttons["languages_parallel_btn"].tap()
        
        // choose the 7th, whatever it is
        app.tables.cells.element(boundBy: 6).tap()

        // back to the home screen
        app.navigationBars["navbar"].buttons.element(boundBy: 0).tap()
        
        app.tables.cells["kgp"].tap()
        app.otherElements["Page 0"].buttons["right arrow blue"].tap()

        snapshot("03_KGPLaw1")
        
        app.navigationBars["navbar"].buttons["nav_home"].tap()
        
        app.tables.cells["fourlaws"].tap()
        app.otherElements["Page 0"].buttons["right arrow blue"].tap()
        
        snapshot("04_4SLLaw1")
        
        app.navigationBars["navbar"]/*@START_MENU_TOKEN@*/.buttons["nav_home"]/*[[".buttons[\"home\"]",".buttons[\"nav_home\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        app.tables.cells["satisfied"].tap()
        app.otherElements["Page 0"].buttons["right arrow blue"].tap()
        app.otherElements["Page 1"].swipeLeft()
        
        snapshot("05_SatisfiedPoint1")
    }
    
}
