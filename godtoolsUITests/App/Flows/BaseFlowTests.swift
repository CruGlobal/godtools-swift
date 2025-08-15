//
//  BaseFlowTests.swift
//  godtoolsUITests
//
//  Created by Levi Eggert on 3/28/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import XCTest

class BaseFlowTests: XCTestCase {
        
    private static let defaultWaitForScreenExistence: TimeInterval = 5
    private static let defaultWaitForButtonExistence: TimeInterval = 2
    
    private(set) var app: XCUIApplication = XCUIApplication()
    private(set) var flowDeepLinkUrl: String = ""
    private(set) var initialScreen: AccessibilityStrings.Screen?
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private static func getNewApp(flowDeepLinkUrl: String) -> XCUIApplication {
        
        let app = XCUIApplication()
        
        let launchEnvironmentWriter = LaunchEnvironmentWriter(environmentName: UITestsLaunchEnvironment.environmentName)
                        
        launchEnvironmentWriter.writeBoolValue(
            launchEnvironment: &app.launchEnvironment,
            key: UITestsLaunchEnvironmentKey.isUITests.value,
            value: true
        )
        
        launchEnvironmentWriter.writeStringValue(
            launchEnvironment: &app.launchEnvironment,
            key: UITestsLaunchEnvironmentKey.urlDeeplink.value,
            value: flowDeepLinkUrl
        )
        
        return app
    }
    
    func launchApp(flowDeepLinkUrl: String, checkInitialScreenExists: AccessibilityStrings.Screen) {
        
        self.app = Self.getNewApp(flowDeepLinkUrl: flowDeepLinkUrl)
        self.flowDeepLinkUrl = flowDeepLinkUrl
        self.initialScreen = checkInitialScreenExists
        
        app.launch()
                
        assertIfInitialScreenDoesntExist()
    }
}

// MARK: - Screen Query and Assertion

extension BaseFlowTests {
    
    func assertIfInitialScreenDoesntExist() {
        
        if let initialScreen = initialScreen {
            
            assertIfScreenDoesNotExist(screenAccessibility: initialScreen)
        }
        else {
            
            XCTAssertNotNil(initialScreen)
        }
    }
    
    func assertIfScreenDoesNotExist(screenAccessibility: AccessibilityStrings.Screen) {
        
        // NOTE:
        //  I needed to place screen accessibility id's on an element within the screen view hierarchy rather than
        //  on the top level view itself.  I noticed in SwiftUI the top level element id was overriding child elements.
        //
        //  For SwiftUI see AccessibilityScreenElementView.swift
        //  For UIKit see UIViewController+AccessibilityScreenId.swift
        //
        // ~Levi
        
        XCTAssertTrue(app.staticTexts[screenAccessibility.id].waitForExistence(timeout: Self.defaultWaitForScreenExistence))
    }
}

// MARK: - Button Query and Assertion

extension BaseFlowTests {
    
    enum ButtonQueryType {
        case firstMatching
        case queryFromButtons
    }
    
    func assertIfButtonDoesNotExistElseTap(buttonAccessibility: AccessibilityStrings.Button, buttonQueryType: ButtonQueryType = .queryFromButtons) {
        
        guard queryButtonWithWaitForExistence(buttonAccessibility: buttonAccessibility, buttonQueryType: buttonQueryType) else {
            let buttonExists: Bool = false
            XCTAssertTrue(buttonExists)
            return
        }
        
        let button: XCUIElement = queryButton(buttonAccessibility: buttonAccessibility, buttonQueryType: buttonQueryType)
        
        XCTAssertTrue(button.exists)
                
        button.tap()
    }
    
    private func queryButtonWithWaitForExistence(buttonAccessibility: AccessibilityStrings.Button, buttonQueryType: ButtonQueryType) -> Bool {
        
        switch buttonQueryType {
        case .queryFromButtons:
            return app.buttons[buttonAccessibility.id].waitForExistence(timeout: Self.defaultWaitForButtonExistence)
        
        case .firstMatching:
            return app.buttons.matching(identifier: buttonAccessibility.id).firstMatch.waitForExistence(timeout: Self.defaultWaitForButtonExistence)
        }
    }
    
    private func queryButton(buttonAccessibility: AccessibilityStrings.Button, buttonQueryType: ButtonQueryType) -> XCUIElement {
        
        switch buttonQueryType {
            
        case .queryFromButtons:
            return app.buttons[buttonAccessibility.id]
            
        case .firstMatching:
            return app.buttons.matching(identifier: buttonAccessibility.id).firstMatch
        }
    }
}
