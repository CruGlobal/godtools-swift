//
//  XCUIApplication+Query.swift
//  godtoolsUITests
//
//  Created by Levi Eggert on 8/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import XCTest

extension XCUIApplication {
    
    func queryDescendants(id: String) -> XCUIElement? {
    
        return descendants(matching: .any).matching(NSPredicate(format: "identifier == %@", id)).allElementsBoundByIndex.first
    }
    
    func queryScreen(screenAccessibility: AccessibilityStrings.Screen, waitForExistence: TimeInterval?) -> XCUIElement {
        
        // NOTE:
        //  I needed to place screen accessibility id's on an element within the screen view hierarchy rather than
        //  on the top level view itself.  I noticed in SwiftUI the top level element id was overriding child elements.
        //
        //  For SwiftUI see AccessibilityScreenElementView.swift
        //  For UIKit see UIViewController+AccessibilityScreenId.swift
        //
        // ~Levi
        
        if let waitForExistence = waitForExistence, queryScreen(screenAccessibility: screenAccessibility).waitForExistence(timeout: waitForExistence) {
            
            return queryScreen(screenAccessibility: screenAccessibility)
        }
        else {
            
            return queryScreen(screenAccessibility: screenAccessibility)
        }
    }
    
    func queryScreen(screenAccessibility: AccessibilityStrings.Screen) -> XCUIElement {
        return staticTexts[screenAccessibility.id]
    }
    
    func queryButton(buttonAccessibility: AccessibilityStrings.Button, waitForExistence: TimeInterval?) -> XCUIElement {
        
        if let waitForExistence = waitForExistence, queryButton(buttonAccessibility: buttonAccessibility).waitForExistence(timeout: waitForExistence) {
            
            return queryButton(buttonAccessibility: buttonAccessibility)
        }
        else {
            
            return queryButton(buttonAccessibility: buttonAccessibility)
        }
    }
    
    func queryButton(buttonAccessibility: AccessibilityStrings.Button) -> XCUIElement {
        return buttons[buttonAccessibility.id]
    }
    
    func queryFirstButtonMatching(buttonAccessibility: AccessibilityStrings.Button, waitForExistence: TimeInterval?) -> XCUIElement {
        
        if let waitForExistence = waitForExistence, queryFirstButtonMatching(buttonAccessibility: buttonAccessibility).waitForExistence(timeout: waitForExistence) {
            
            return queryFirstButtonMatching(buttonAccessibility: buttonAccessibility)
        }
        else {
            
            return queryFirstButtonMatching(buttonAccessibility: buttonAccessibility)
        }
    }
    
    func queryFirstButtonMatching(buttonAccessibility: AccessibilityStrings.Button) -> XCUIElement {
        
        let matchingButtons = buttons.matching(identifier: buttonAccessibility.id)
        
        if matchingButtons.count > 0 {
            
            return matchingButtons.element(boundBy: 0)
        }
        else {
            
            XCTAssertFalse(matchingButtons.count == 0)
            
            return queryButton(buttonAccessibility: buttonAccessibility)
        }
    }
}
