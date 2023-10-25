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
    
    func queryScreen(screenAccessibility: AccessibilityStrings.Screen) -> XCUIElement {
    
        // NOTE: See AccessibilityScreenElementView.swift ~Levi
        
        return staticTexts[screenAccessibility.id]
    }
    
    func queryButton(buttonAccessibility: AccessibilityStrings.Button) -> XCUIElement {
        
        return buttons[buttonAccessibility.id]
    }
}
