//
//  OnboardingUITests.swift
//  godtoolsTests
//
//  Created by Ryan Carlson on 4/16/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import XCTest

class OnboardingUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments.append("UI-Testing")
        
        app.launch()
    }
    
    func testAddLanguagesButtonPress() {
        let app = XCUIApplication()
        app.buttons[GTAccessibilityConstants.Onboarding.languagesOkayButton].tap()

        let homeTableView = app.tables[GTAccessibilityConstants.Home.homeTableView]
        XCTAssert(homeTableView.exists)
        XCTAssert(homeTableView.cells.count == 4)
    }
}
