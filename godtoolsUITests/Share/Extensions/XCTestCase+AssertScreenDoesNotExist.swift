//
//  XCTestCase+AssertScreenDoesNotExist.swift
//  godtoolsUITests
//
//  Created by Levi Eggert on 10/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {
    
    func assertIfScreenDoesNotExist(app: XCUIApplication, screenAccessibility: AccessibilityStrings.Screen, waitForExistence: TimeInterval?) {
        
        if let waitForExistence = waitForExistence {
            
            if app.staticTexts[screenAccessibility.id].waitForExistence(timeout: waitForExistence) {
                
                assertIfScreenDoesNotExist(app: app, screenAccessibility: screenAccessibility)
            }
        }
        else {
            
            assertIfScreenDoesNotExist(app: app, screenAccessibility: screenAccessibility)
        }
    }
    
    func assertIfScreenDoesNotExist(app: XCUIApplication, screenAccessibility: AccessibilityStrings.Screen) {
        
        let screen = app.queryScreen(screenAccessibility: screenAccessibility)
        
        XCTAssertTrue(screen.exists)
    }
}
