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
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
