//
//  BaseFlowTests.swift
//  godtoolsUITests
//
//  Created by Levi Eggert on 3/28/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import XCTest
@testable import godtools

class BaseFlowTests: XCTestCase {
        
    private static let defaultWaitForScreenExistence: TimeInterval = 5
    
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
    
    func assertIfInitialScreenDoesntExist() {
        
        if let initialScreen = initialScreen {
            
            assertIfScreenDoesNotExist(screenAccessibility: initialScreen)
        }
        else {
            
            XCTAssertNotNil(initialScreen)
        }
    }
    
    func assertIfScreenDoesNotExist(screenAccessibility: AccessibilityStrings.Screen) {
        
        XCTAssertTrue(app.staticTexts[screenAccessibility.id].waitForExistence(timeout: Self.defaultWaitForScreenExistence))
    }
}
