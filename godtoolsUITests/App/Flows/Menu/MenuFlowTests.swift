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
        
        super.assertIfInitialScreenDoesntExist(app: app)
    }
    
    func testNavigationToMenu() {
        
        launchApp()
        
        navigateToMenu()
    }
    
    private func navigateToMenu() {
        
        let menuButton = app.queryButton(buttonAccessibility: .dashboardMenu)
        
        XCTAssertTrue(menuButton.exists)
        
        menuButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .menu, waitForExistence: AppFlowTests.defaultWaitForScreenExistence)
    }
    
    func testNavigationToTutorial() {
        
        launchApp()
        
        navigateToMenu()
        
        let tutorialButton = app.queryButton(buttonAccessibility: .tutorial)
        
        XCTAssertTrue(tutorialButton.exists)
        
        tutorialButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .tutorial, waitForExistence: AppFlowTests.defaultWaitForScreenExistence)
    }
    
    func testNavigationToLanguageSettings() {
        
        launchApp()
        
        navigateToMenu()
        
        let languageSettingsButton = app.queryButton(buttonAccessibility: .languageSettings)
        
        XCTAssertTrue(languageSettingsButton.exists)
        
        languageSettingsButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .languageSettings, waitForExistence: AppFlowTests.defaultWaitForScreenExistence)
    }
    
    func testNavigationToCreateAccount() {
        
        launchApp()
        
        navigateToMenu()
        
        let createAccountButton = app.queryButton(buttonAccessibility: .createAccount)
        
        XCTAssertTrue(createAccountButton.exists)
        
        createAccountButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .createAccount, waitForExistence: AppFlowTests.defaultWaitForScreenExistence)
    }
    
    func testNavigationToLogin() {
        
        launchApp()
        
        navigateToMenu()
        
        let loginButton = app.queryButton(buttonAccessibility: .login)
        
        XCTAssertTrue(loginButton.exists)
        
        loginButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .login, waitForExistence: AppFlowTests.defaultWaitForScreenExistence)
    }
    
    func testNavigationToSendFeedback() {
        
        launchApp()
        
        navigateToMenu()
        
        let sendFeedbackButton = app.queryButton(buttonAccessibility: .sendFeedback)
        
        XCTAssertTrue(sendFeedbackButton.exists)
        
        sendFeedbackButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .sendFeedback, waitForExistence: AppFlowTests.defaultWaitForScreenExistence)
    }
    
    func testNavigationToReportABug() {
        
        launchApp()
        
        navigateToMenu()
        
        let reportABugButton = app.queryButton(buttonAccessibility: .reportABug)
        
        XCTAssertTrue(reportABugButton.exists)
        
        reportABugButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .reportABug, waitForExistence: AppFlowTests.defaultWaitForScreenExistence)
    }
    
    func testNavigationToAskAQuestion() {
        
        launchApp()
        
        navigateToMenu()
        
        let askAQuestionButton = app.queryButton(buttonAccessibility: .askAQuestion)
        
        XCTAssertTrue(askAQuestionButton.exists)
        
        askAQuestionButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .askAQuestion, waitForExistence: AppFlowTests.defaultWaitForScreenExistence)
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
//        assertIfScreenDoesNotExist(app: app, screenAccessibility: .leaveAReview)
//    }
    
    func testNavigationToShareAStoryWithUs() {
        
        launchApp()
        
        navigateToMenu()
        
        let askAQuestionButton = app.queryButton(buttonAccessibility: .shareAStoryWithUs)
        
        XCTAssertTrue(askAQuestionButton.exists)
        
        askAQuestionButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .shareAStoryWithUs, waitForExistence: AppFlowTests.defaultWaitForScreenExistence)
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
//        assertIfScreenDoesNotExist(app: app, screenAccessibility: .shareGodTools, waitForExistence: AppFlowTests.defaultWaitForScreenExistence)
//    }
    
    func testNavigationToTermsOfUse() {
        
        launchApp()
        
        navigateToMenu()
        
        let termsOfUseButton = app.queryButton(buttonAccessibility: .termsOfUse)
        
        XCTAssertTrue(termsOfUseButton.exists)
        
        termsOfUseButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .termsOfUse, waitForExistence: AppFlowTests.defaultWaitForScreenExistence)
    }
    
    func testNavigationToPrivacyPolicy() {
        
        launchApp()
        
        navigateToMenu()
        
        let privacyPolicyButton = app.queryButton(buttonAccessibility: .privacyPolicy)
        
        XCTAssertTrue(privacyPolicyButton.exists)
        
        privacyPolicyButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .privacyPolicy, waitForExistence: AppFlowTests.defaultWaitForScreenExistence)
    }
    
    func testNavigationToCopyrightInfo() {
        
        launchApp()
        
        navigateToMenu()
        
        let copyrightInfoButton = app.queryButton(buttonAccessibility: .copyrightInfo)
        
        XCTAssertTrue(copyrightInfoButton.exists)
        
        copyrightInfoButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .copyrightInfo, waitForExistence: AppFlowTests.defaultWaitForScreenExistence)
    }
}
