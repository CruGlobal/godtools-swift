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
    
    func launchApp(flowDeepLinkUrl: String, initialScreen: AccessibilityStrings.Screen) {
        
        self.app = XCUIApplication()
        self.flowDeepLinkUrl = flowDeepLinkUrl
        self.initialScreen = initialScreen
                        
        app.launchEnvironment[LaunchEnvironmentKey.urlDeeplink.value] = flowDeepLinkUrl
          
        // I noticed the documentated stated "Unlike launch(), a call to activate() will not terminate the existing instance if the application is already running." (https://developer.apple.com/documentation/xctest/xcuiapplication/2873317-activate)
        // I'm curious if using activate() will resolve the random UITests failing with "The test runner failed to initialize for UI testing. (Underlying Error: Timed out while loading Accessibility".
        app.activate()
        //app.launch()
                
        checkInitialScreenExists(app: app)
    }
    
    func checkInitialScreenExists(app: XCUIApplication) {
        
        if let initialScreen = initialScreen {
            
            assertIfScreenDoesNotExist(app: app, screenAccessibility: initialScreen)
        }
        else {
            
            XCTAssertNotNil(initialScreen)
        }
    }
}
