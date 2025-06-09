//
//  MenuFlowTests.swift
//  godtoolsUITests
//
//  Created by Levi Eggert on 7/18/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import XCTest
@testable import godtools

class MenuFlowTests: BaseFlowTests {
        
    private func launchApp() {
        
        super.launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/dashboard/tools",
            checkInitialScreenExists: .dashboardTools
        )
    }
    
    func testInitialScreenIsDashboard() {
        
        launchApp()
        
        super.assertIfInitialScreenDoesntExist()
    }
    
    func testNavigationToMenu() {
        
        launchApp()
        
        navigateToMenu()
    }
    
    private func navigateToMenu() {
        
        let menuButton = app.queryButton(buttonAccessibility: .dashboardMenu)
        
        XCTAssertTrue(menuButton.exists)
        
        menuButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .menu)
    }
    
    func testNavigationToTutorial() {
        
        launchApp()
        
        navigateToMenu()
        
        let tutorialButton = app.queryButton(buttonAccessibility: .tutorial)
        
        XCTAssertTrue(tutorialButton.exists)
        
        tutorialButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .tutorial)
    }
    
    func testNavigationToLanguageSettings() {
        
        launchApp()
        
        navigateToMenu()
        
        let languageSettingsButton = app.queryButton(buttonAccessibility: .languageSettings)
        
        XCTAssertTrue(languageSettingsButton.exists)
        
        languageSettingsButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .languageSettings)
    }
    
    func testNavigationToCreateAccount() {
        
        launchApp()
        
        navigateToMenu()
        
        let createAccountButton = app.queryButton(buttonAccessibility: .createAccount)
        
        XCTAssertTrue(createAccountButton.exists)
        
        createAccountButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .createAccount)
    }
    
    func testNavigationToLogin() {
        
        launchApp()
        
        navigateToMenu()
        
        let loginButton = app.queryButton(buttonAccessibility: .login)
        
        XCTAssertTrue(loginButton.exists)
        
        loginButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .login)
    }
    
    func testNavigationToSendFeedback() {
        
        launchApp()
        
        navigateToMenu()
        
        let sendFeedbackButton = app.queryButton(buttonAccessibility: .sendFeedback)
        
        XCTAssertTrue(sendFeedbackButton.exists)
        
        sendFeedbackButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .sendFeedback)
    }
    
    func testNavigationToReportABug() {
        
        launchApp()
        
        navigateToMenu()
        
        let reportABugButton = app.queryButton(buttonAccessibility: .reportABug)
        
        XCTAssertTrue(reportABugButton.exists)
        
        reportABugButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .reportABug)
    }
    
    func testNavigationToAskAQuestion() {
        
        launchApp()
        
        navigateToMenu()
        
        let askAQuestionButton = app.queryButton(buttonAccessibility: .askAQuestion)
        
        XCTAssertTrue(askAQuestionButton.exists)
        
        askAQuestionButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .askAQuestion)
    }
    
//    func testNavigationToLeaveAReview() {
//        
//        launchApp()
//        
//        navigateToMenu()
//        
//        let leaveAReviewButton = app.queryButton(buttonAccessibility: .leaveAReview)
//        
//        XCTAssertTrue(leaveAReviewButton.exists)
//        
//        leaveAReviewButton.tap()
//        
//        assertIfScreenDoesNotExist(screenAccessibility: .leaveAReview)
//    }
    
    func testNavigationToShareAStoryWithUs() {
        
        launchApp()
        
        navigateToMenu()
        
        let askAQuestionButton = app.queryButton(buttonAccessibility: .shareAStoryWithUs)
        
        XCTAssertTrue(askAQuestionButton.exists)
        
        askAQuestionButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .shareAStoryWithUs)
    }
    
//    func testNavigationToShareGodTools() {
//        
//        launchApp()
//        
//        navigateToMenu()
//        
//        let shareGodToolsButton = app.queryButton(buttonAccessibility: .shareGodTools)
//        
//        XCTAssertTrue(shareGodToolsButton.exists)
//        
//        shareGodToolsButton.tap()
//        
//        assertIfScreenDoesNotExist(screenAccessibility: .shareGodTools)
//    }
    
    func testNavigationToTermsOfUse() {
        
        launchApp()
        
        navigateToMenu()
        
        let termsOfUseButton = app.queryButton(buttonAccessibility: .termsOfUse)
        
        XCTAssertTrue(termsOfUseButton.exists)
        
        termsOfUseButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .termsOfUse)
    }
    
    func testNavigationToPrivacyPolicy() {
        
        launchApp()
        
        navigateToMenu()
        
        let privacyPolicyButton = app.queryButton(buttonAccessibility: .privacyPolicy)
        
        XCTAssertTrue(privacyPolicyButton.exists)
        
        privacyPolicyButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .privacyPolicy)
    }
    
    func testNavigationToCopyrightInfo() {
        
        launchApp()
        
        navigateToMenu()
        
        let copyrightInfoButton = app.queryButton(buttonAccessibility: .copyrightInfo)
        
        XCTAssertTrue(copyrightInfoButton.exists)
        
        copyrightInfoButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .copyrightInfo)
    }
}
