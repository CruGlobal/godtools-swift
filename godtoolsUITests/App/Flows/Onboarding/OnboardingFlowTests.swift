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

class OnboardingFlowTests: BaseFlowTests {
        
    private func launchApp(appLanguageCode: String? = nil) {
        
        let languageCode: String = appLanguageCode ?? LanguageCodeDomainModel.english.value
                
        super.launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/ui_tests/onboarding" + "?" + "appLanguageCode=" + languageCode,
            checkInitialScreenExists: .onboardingTutorial
        )
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
        assertIfScreenDoesNotExist(screenAccessibility: .watchOnboardingTutorialVideo)
    }
    
    private func navigateBackToOnboardingTutorialFromWatchOnboardingTutorialVideo(app: XCUIApplication) {
        
        let closeVideoButton = app.queryButton(buttonAccessibility: .close)
        
        XCTAssertTrue(closeVideoButton.exists)
        
        closeVideoButton.tap()
        
        super.assertIfInitialScreenDoesntExist()
    }
    
    func testNavigationThroughTutorialPagesUsingNextTutorialPageButton() {
        
        launchApp(appLanguageCode: LanguageCodeDomainModel.english.value)
        
        let nextTutorialPageButton = getNextTutorialPageButton(app: app)
        
        XCTAssertTrue(nextTutorialPageButton.exists)
        
        assertIfScreenDoesNotExist(screenAccessibility: .onboardingTutorialPage1)
        
        nextTutorialPageButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .onboardingTutorialPage2)
        
        nextTutorialPageButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .onboardingTutorialPage3)
        
        nextTutorialPageButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .onboardingTutorialPage4)
    }
    
    func testSkippingOnboardingNavigatesToDashboardFavorites() {
     
        launchApp()
        
        let nextTutorialPageButton = getNextTutorialPageButton(app: app)
        
        XCTAssertTrue(nextTutorialPageButton.exists)
        
        assertIfScreenDoesNotExist(screenAccessibility: .onboardingTutorialPage1)
        
        nextTutorialPageButton.tap()
        
        let skipTutorialButton = getSkipTutorialButton(app: app)
        
        XCTAssertTrue(skipTutorialButton.exists)
        
        skipTutorialButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .dashboardFavorites)
    }
}
