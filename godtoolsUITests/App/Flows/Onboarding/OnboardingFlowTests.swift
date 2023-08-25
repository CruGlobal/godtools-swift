//
//  OnboardingFlowTests.swift
//  godtoolsUITests
//
//  Created by Levi Eggert on 8/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import XCTest
@testable import godtools
import SwiftUI

class OnboardingFlowTests: XCTestCase {
    
    private let onboardingDeepLinkUrl: String = "godtools://org.cru.godtools/onboarding"
    
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
    
    func testOnboardingWillLaunchToTutorial() {
        
        let app = XCUIApplication()
        
        app.launchEnvironment[LaunchEnvironmentKey.urlDeeplink.value] = onboardingDeepLinkUrl
                
        app.launch()
                
        let tutorialScreen = app.queryScreen(screenAccessibility: .onboardingTutorial)
                
        XCTAssertTrue(tutorialScreen?.exists ?? false)
    }
    
    func testOnboardingWillPresentWatchOnboardingTutorialVideo() {
        
        let app = XCUIApplication()
        
        app.launchEnvironment[LaunchEnvironmentKey.urlDeeplink.value] = onboardingDeepLinkUrl
                
        app.launch()
                
        let tutorialScreen = app.queryScreen(screenAccessibility: .onboardingTutorial)
        let watchVideoButton = app.queryButton(buttonAccessibility: .watchOnboardingTutorialVideo)
                        
        XCTAssertTrue(tutorialScreen?.exists ?? false)
        XCTAssertTrue(watchVideoButton.exists)
        
        watchVideoButton.tap()
        
        let watchOnboardingVideoTutorialScreen = app.queryScreen(screenAccessibility: .watchOnboardingTutorialVideo)
        
        XCTAssertTrue(watchOnboardingVideoTutorialScreen?.exists ?? false)
    }
}
