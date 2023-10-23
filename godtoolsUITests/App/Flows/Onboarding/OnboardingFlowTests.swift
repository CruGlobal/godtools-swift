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
    
    private let onboardingDeepLinkUrl: String = "godtools://org.cru.godtools/onboarding"
    
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
    
    private func launchApp(appLanguageCode: LanguageCodeDomainModel? = nil) {
        
        self.app = XCUIApplication()
        
        let languageCode: String = appLanguageCode?.value ?? LanguageCodeDomainModel.english.value
        
        let deepLinkUrl: String = onboardingDeepLinkUrl + "?" + "appLanguageCode=" + languageCode
        
        app.launchEnvironment[LaunchEnvironmentKey.urlDeeplink.value] = deepLinkUrl
                
        app.launch()
                
        checkInitialScreenIsOnboardingTutorial(app: app)
    }
    
    private func checkInitialScreenIsOnboardingTutorial(app: XCUIApplication) {
        
        let initialScreenIsTutorialScreen = app.queryScreen(screenAccessibility: .onboardingTutorial)
                
        XCTAssertTrue(initialScreenIsTutorialScreen.exists)
    }
    
    private func assertIfScreenDoesNotExist(screenAccessibility: AccessibilityStrings.Screen) {
        
        let screen = app.queryScreen(screenAccessibility: screenAccessibility)
        
        XCTAssertTrue(screen.exists)
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
        
        assertIfScreenDoesNotExist(screenAccessibility: .appLanguages)
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
        if app.staticTexts[AccessibilityStrings.Screen.watchOnboardingTutorialVideo.id].waitForExistence(timeout: 1) {
            
            let watchOnboardingVideoTutorialScreen = app.queryScreen(screenAccessibility: .watchOnboardingTutorialVideo)
            
            XCTAssertTrue(watchOnboardingVideoTutorialScreen.exists)
        }
    }
    
    private func navigateBackToOnboardingTutorialFromWatchOnboardingTutorialVideo(app: XCUIApplication) {
        
        let closeVideoButton = app.queryButton(buttonAccessibility: .closeOnboardingTutorialVideo)
        
        XCTAssertTrue(closeVideoButton.exists)
        
        closeVideoButton.tap()
        
        checkInitialScreenIsOnboardingTutorial(app: app)
    }
    
    func testSkippingOnboardingTutorialNavigatesToQuickStartWhenQuickStartIsAvailable() {
              
        launchApp(appLanguageCode: .english)
        
        let nextTutorialPageButton = getNextTutorialPageButton(app: app)
        
        XCTAssertTrue(nextTutorialPageButton.exists)
        
        nextTutorialPageButton.tap()
        
        let skipButton = getSkipTutorialButton(app: app)
        
        XCTAssertTrue(skipButton.exists)
        
        skipButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .onboardingQuickStart)
    }
    
    func testSkippingOnboardingTutorialNavigatesToDashboardWhenQuickStartIsNotAvailable() {
              
        launchApp(appLanguageCode: .portuguese) // NOTE: Language will have to be an available app language that is not supported by quick start. ~Levi
        
        let nextTutorialPageButton = getNextTutorialPageButton(app: app)
        
        XCTAssertTrue(nextTutorialPageButton.exists)
        
        nextTutorialPageButton.tap()
        
        let skipButton = getSkipTutorialButton(app: app)
        
        XCTAssertTrue(skipButton.exists)
        
        skipButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .dashboardFavorites)
    }
}
