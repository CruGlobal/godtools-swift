//
//  OnboardingFlowTests.swift
//  godtoolsUITests
//
//  Created by Levi Eggert on 8/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import XCTest

class OnboardingFlowTests: BaseFlowTests {
        
    private func launchAppToOnboardingTutorial(appLanguageCode: String? = nil) {
        
        let languageCode: String = appLanguageCode ?? LanguageCodeDomainModel.english.value
                
        super.launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/ui_tests/onboarding" + "?" + "appLanguageCode=" + languageCode,
            checkInitialScreenExists: .onboardingTutorial
        )
    }
    
    func testAppLaunchedToOnboardingTutorial() {
        
        launchAppToOnboardingTutorial()
    }
    
    func testNavigationToChooseAppLanguage() {
              
        launchAppToOnboardingTutorial()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .chooseAppLanguage)
        
        assertIfScreenDoesNotExist(screenAccessibility: .appLanguages)
    }
    
    func testNavigationToWatchOnboardingVideoTutorialAndNavigationBackToOnboardingTutorial() {
              
        launchAppToOnboardingTutorial()
        
        navigateToWatchOnboardingVideoTutorial(app: app)
        
        navigateBackToOnboardingTutorialFromWatchOnboardingTutorialVideo(app: app)
    }
    
    private func navigateToWatchOnboardingVideoTutorial(app: XCUIApplication) {
                
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .watchOnboardingTutorialVideo)
        
        assertIfScreenDoesNotExist(screenAccessibility: .watchOnboardingTutorialVideo)
    }
    
    private func navigateBackToOnboardingTutorialFromWatchOnboardingTutorialVideo(app: XCUIApplication) {
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .close)
        
        super.assertIfInitialScreenDoesntExist()
    }
    
    func testFirstContinueButtonTapNavigatesToChooseAppLanguage() {
        
        launchAppToOnboardingTutorial()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .continueForward, buttonQueryType: .exactMatch)
        
        assertIfScreenDoesNotExist(screenAccessibility: .appLanguages)
    }
    
    func testNavigationThroughTutorialPagesUsingNextTutorialPageButton() {
        
        launchAppToOnboardingTutorial()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .continueForward, buttonQueryType: .exactMatch)
        
        assertIfScreenDoesNotExist(screenAccessibility: .appLanguages)
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .appLanguagesNavBack, buttonQueryType: .exactMatch)
        
        assertIfScreenDoesNotExist(screenAccessibility: .onboardingTutorial)
        
        tapWhileExists(buttonAccessibility: .continueForward)
        
        assertIfButtonDoesNotExist(buttonAccessibility: .getStarted)
    }
    
    func testSkippingOnboardingNavigatesToDashboardFavorites() {
     
        launchAppToOnboardingTutorial()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .continueForward)
        
        assertIfScreenDoesNotExist(screenAccessibility: .appLanguages)
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .appLanguagesNavBack, buttonQueryType: .exactMatch)
        
        assertIfScreenDoesNotExist(screenAccessibility: .onboardingTutorial)
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .continueForward)
                
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .skip)
        
        assertIfScreenDoesNotExist(screenAccessibility: .dashboardFavorites)
    }
}
