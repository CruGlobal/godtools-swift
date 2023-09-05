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
    
    func queryScreen(screenAccessibility: AccessibilityStrings.Screen) -> XCUIElement? {
    
        return descendants(matching: .any).matching(NSPredicate(format: "identifier == %@", screenAccessibility.id)).allElementsBoundByIndex.first
    }
    
    func queryButton(buttonAccessibility: AccessibilityStrings.Button) -> XCUIElement {
        
        return buttons[buttonAccessibility.id]
    }
}
