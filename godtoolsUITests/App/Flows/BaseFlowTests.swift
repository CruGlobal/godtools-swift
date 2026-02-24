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
        
    private static let defaultWaitForScreenExistence: TimeInterval = 2
    private static let defaultWaitForButtonExistence: TimeInterval = 2
    private static let defaultButtonQueryType: ButtonQueryType = .exactMatch
    
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
    
    func launchApp(flowDeepLinkUrl: String, checkInitialScreenExists: AccessibilityStrings.Screen?) {
        
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
    }
    
    func assertIfScreenDoesNotExist(screenAccessibility: AccessibilityStrings.Screen, shouldWaitForExistence: Bool = true) {
        
        // NOTE:
        //  I needed to place screen accessibility id's on an element within the screen view hierarchy rather than
        //  on the top level view itself.  I noticed in SwiftUI the top level element id was overriding child elements.
        //
        //  For SwiftUI see AccessibilityScreenElementView.swift
        //  For UIKit see UIViewController+AccessibilityScreenId.swift
        //
        // ~Levi
        
        if shouldWaitForExistence {
            XCTAssertTrue(app.staticTexts[screenAccessibility.id].waitForExistence(timeout: Self.defaultWaitForScreenExistence))
        }
        else {
            XCTAssertTrue(app.staticTexts[screenAccessibility.id].exists)
        }
    }
}

// MARK: - Button Query and Assertion

extension BaseFlowTests {
    
    enum ButtonQueryType {
        case exactMatch // If only one SwiftUI Button exists with this identifier.
        case firstMatch // If multiple SwiftUI Buttons exist with the same identifier. Use the first matching in the query.
        case searchDescendants // For non SwiftUI Buttons.  This could be VStack, ZStack, etc.
    }
    
    func assertIfButtonDoesNotExist(buttonAccessibility: AccessibilityStrings.Button, buttonQueryType: ButtonQueryType = BaseFlowTests.defaultButtonQueryType) {
        
        assertIfButtonDoesNotExist(buttonId: buttonAccessibility.id, buttonQueryType: buttonQueryType, shouldTapButton: false)
    }
    
    func assertIfButtonDoesNotExistElseTap(buttonAccessibility: AccessibilityStrings.Button, buttonQueryType: ButtonQueryType = BaseFlowTests.defaultButtonQueryType) {
        
        assertIfButtonDoesNotExist(buttonId: buttonAccessibility.id, buttonQueryType: buttonQueryType, shouldTapButton: true)
    }
    
    func tapWhileExists(buttonAccessibility: AccessibilityStrings.Button, buttonQueryType: ButtonQueryType = BaseFlowTests.defaultButtonQueryType, maxTapCount: Int = 10) {
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: buttonAccessibility, buttonQueryType: buttonQueryType)
        
        var tapCount: Int = 1
        var buttonExists: Bool = true
        
        while buttonExists && tapCount < maxTapCount {
            
            if queryButtonWithWaitForExistence(buttonId: buttonAccessibility.id, buttonQueryType: buttonQueryType),
               let button = queryButton(buttonId: buttonAccessibility.id, buttonQueryType: buttonQueryType)  {
                
                tapCount += 1
                buttonExists = true
                
                button.tap()
                
            }
            else {
                
                buttonExists = false
            }
        }
        
        XCTAssertFalse(tapCount == maxTapCount, "Reached max button tap count.  Either this is intended or there is an error in the app navigation.")
    }
    
    func assertIfButtonDoesNotExistElseTap(buttonId: String, buttonQueryType: ButtonQueryType = BaseFlowTests.defaultButtonQueryType) {
        assertIfButtonDoesNotExist(buttonId: buttonId, buttonQueryType: buttonQueryType, shouldTapButton: true)
    }
    
    func assertIfButtonDoesNotExist(buttonId: String, buttonQueryType: ButtonQueryType = BaseFlowTests.defaultButtonQueryType, shouldTapButton: Bool) {
        
        guard queryButtonWithWaitForExistence(buttonId: buttonId, buttonQueryType: buttonQueryType) else {
            let buttonExists: Bool = false
            XCTAssertTrue(buttonExists)
            return
        }
        
        let button = queryButton(buttonId: buttonId, buttonQueryType: buttonQueryType)
        
        assertIfButtonDoesNotExist(button: button)
                
        if shouldTapButton {
            button?.tap()
        }
    }
    
    func assertIfButtonDoesNotExist(button: XCUIElement?) {
        
        guard let button = button else {
            XCTAssertNotNil(button, "Found nil element.")
            return
        }
        
        XCTAssertTrue(button.exists)
    }
    
    func queryButtonWithWaitForExistence(buttonId: String, buttonQueryType: ButtonQueryType) -> Bool {
        
        guard let button = queryButton(buttonId: buttonId, buttonQueryType: buttonQueryType) else {
            return true
        }
        
        return button.waitForExistence(timeout: Self.defaultWaitForButtonExistence)
    }
    
    func queryButton(buttonId: String, buttonQueryType: ButtonQueryType) -> XCUIElement? {
        
        switch buttonQueryType {
        case .exactMatch:
            return app.buttons[buttonId]
            
        case .firstMatch:
            return app.buttons.matching(identifier: buttonId).firstMatch
            
        case .searchDescendants:
            return app.queryDescendants(id: buttonId)
        }
    }
}
