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
//
//
//        snapshot("02_LanguagesScreen")
//
//
//
//        snapshot("03_KGPLaw1")
//        snapshot("04_4SLLaw1")
//
//        snapshot("05_SatisfiedPoint1")
    }
    
}
