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
}
