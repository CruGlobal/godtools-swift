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
    
    func testAddToolsViewButtonPress() {
        let app = XCUIApplication()
        app.buttons[GTAccessibilityConstants.Onboarding.toolsOkayButton].tap()

        XCTAssert(app.buttons[GTAccessibilityConstants.Onboarding.languagesOkayButton].exists)
        XCTAssert(app.staticTexts[GTAccessibilityConstants.Onboarding.addLanguagesLabel].exists)
    }
    
    func testAddToolsViewSwipeRight() {
        let app = XCUIApplication()

        app.otherElements["onboarding_add_tools_view"].swipeLeft()
        
        XCTAssert(app.buttons[GTAccessibilityConstants.Onboarding.languagesOkayButton].exists)
        XCTAssert(app.staticTexts[GTAccessibilityConstants.Onboarding.addLanguagesLabel].exists)
    }
}
