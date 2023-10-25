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
        
        // NOTE:
        //  I needed to place screen accessibility id's on an element within the screen view hierarchy rather than
        //  on the top level view itself.  I noticed in SwiftUI the top level element id was overriding child elements.
        //
        //  For SwiftUI see AccessibilityScreenElementView.swift
        //  For UIKit see UIViewController+AccessibilityScreenId.swift
        //
        // ~Levi
        
        return staticTexts[screenAccessibility.id]
    }
    
    func queryButton(buttonAccessibility: AccessibilityStrings.Button) -> XCUIElement {
        
        return buttons[buttonAccessibility.id]
    }
}
