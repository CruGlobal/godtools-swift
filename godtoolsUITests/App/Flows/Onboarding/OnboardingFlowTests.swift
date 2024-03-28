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
import Combine

class OnboardingFlowTests: XCTestCase {
    
    private let onboardingDeepLinkUrl: String = "godtools://org.cru.godtools/ui_tests/onboarding"
    
    private var app: XCUIApplication = XCUIApplication()
    
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
    
    private func launchApp(appLanguageCode: String? = nil) {
        
        self.app = XCUIApplication()
        
        let languageCode: String = appLanguageCode ?? LanguageCodeDomainModel.english.value
        
        let deepLinkUrl: String = onboardingDeepLinkUrl + "?" + "appLanguageCode=" + languageCode
        
        app.launchEnvironment[LaunchEnvironmentKey.urlDeeplink.value] = deepLinkUrl
                
        app.launch()
                
        checkInitialScreenIsOnboardingTutorial(app: app)
    }
    
    private func checkInitialScreenIsOnboardingTutorial(app: XCUIApplication) {
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .onboardingTutorial)
    }
    
    private func getNextTutorialPageButton(app: XCUIApplication) -> XCUIElement {
        return app.queryButton(buttonAccessibility: .nextOnboardingTutorial)
    }
    
    private func getSkipTutorialButton(app: XCUIApplication) -> XCUIElement {
        return app.queryButton(buttonAccessibility: .skipOnboardingTutorial)
    }
    
    // MARK: - Tests
    
    func testNavigationToChooseAppLanguage() {
              
        launchApp()
        
        let chooseAppLanguageButton = app.queryButton(buttonAccessibility: AccessibilityStrings.Button.chooseAppLanguage)
        
        XCTAssertTrue(chooseAppLanguageButton.exists)
        
        chooseAppLanguageButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .appLanguages)
    }
    
    func testNavigationToWatchOnboardingVideoTutorialAndNavigationBackToOnboardingTutorial() {
              
        launchApp()
        
        navigateToWatchOnboardingVideoTutorial(app: app)
        
        navigateBackToOnboardingTutorialFromWatchOnboardingTutorialVideo(app: app)
    }
    
    private func navigateToWatchOnboardingVideoTutorial(app: XCUIApplication) {
                
        let watchVideoButton = app.queryButton(buttonAccessibility: .watchOnboardingTutorialVideo)
        
        XCTAssertTrue(watchVideoButton.exists)
        
        watchVideoButton.tap()
        
        // Adding waitForExistence I believe helped with the fact this view is presented with an animation. ~Levi
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .watchOnboardingTutorialVideo, waitForExistence: 1)
    }
    
    private func navigateBackToOnboardingTutorialFromWatchOnboardingTutorialVideo(app: XCUIApplication) {
        
        let closeVideoButton = app.queryButton(buttonAccessibility: .closeOnboardingTutorialVideo)
        
        XCTAssertTrue(closeVideoButton.exists)
        
        closeVideoButton.tap()
        
        checkInitialScreenIsOnboardingTutorial(app: app)
    }
    
    func testNavigationThroughTutorialPagesUsingNextTutorialPageButton() {
        
        launchApp(appLanguageCode: LanguageCodeDomainModel.english.value)
        
        let nextTutorialPageButton = getNextTutorialPageButton(app: app)
        
        XCTAssertTrue(nextTutorialPageButton.exists)
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .onboardingTutorialPage1)
        
        nextTutorialPageButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .onboardingTutorialPage2)
        
        nextTutorialPageButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .onboardingTutorialPage3)
        
        nextTutorialPageButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .onboardingTutorialPage4)
    }
    
    func testSkippingOnboardingNavigatesToDashboardFavorites() {
     
        launchApp()
        
        let nextTutorialPageButton = getNextTutorialPageButton(app: app)
        
        XCTAssertTrue(nextTutorialPageButton.exists)
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .onboardingTutorialPage1)
        
        nextTutorialPageButton.tap()
        
        let skipTutorialButton = getSkipTutorialButton(app: app)
        
        XCTAssertTrue(skipTutorialButton.exists)
        
        skipTutorialButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .dashboardFavorites)
    }
}
