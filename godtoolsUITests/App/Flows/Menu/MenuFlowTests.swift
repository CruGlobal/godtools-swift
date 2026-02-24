//
//  MenuFlowTests.swift
//  godtoolsUITests
//
//  Created by Levi Eggert on 7/18/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import XCTest

class MenuFlowTests: BaseFlowTests {
        
    private func launchAppToMenu() {
        
        super.launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/ui_tests/menu",
            checkInitialScreenExists: .menu
        )
    }
    /*
    func testMenuButtonExistsInDashboard() {
        
        // TODO: Need to fix this test.  For some reason can't find menu button in dashboard. ~Levi
        
        super.launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/dashboard/tools",
            checkInitialScreenExists: nil
        )
        
        assertIfScreenDoesNotExist(screenAccessibility: .dashboardTools, shouldWaitForExistence: false)
                
        let menuButton = queryButton(
            buttonId: AccessibilityStrings.Button.dashboardMenu.id,
            buttonQueryType: .firstMatch
        )
        
        assertIfButtonDoesNotExist(button: menuButton)
        
        menuButton?.tap()
        
        //assertIfButtonDoesNotExist(buttonAccessibility: .dashboardMenu, buttonQueryType: .exactMatch)
        
        //assertIfButtonDoesNotExistElseTap(buttonAccessibility: .dashboardMenu, buttonQueryType: .exactMatch)
        
        assertIfScreenDoesNotExist(screenAccessibility: .menu)
    }*/
    
    func testInitialScreenIsMenu() {
        
        launchAppToMenu()
    }
    
    func testNavigationToTutorial() {
        
        launchAppToMenu()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .tutorial)
        
        assertIfScreenDoesNotExist(screenAccessibility: .tutorial)
    }
    
    func testNavigationToLanguageSettings() {
        
        launchAppToMenu()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .languageSettings)
        
        assertIfScreenDoesNotExist(screenAccessibility: .languageSettings)
    }
    
    func testNavigationToLocalizationSettings() {
        
        launchAppToMenu()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .localizationSettings)
        
        assertIfScreenDoesNotExist(screenAccessibility: .localizationSettings)
    }
    
    func testNavigationToCreateAccount() {
        
        launchAppToMenu()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .createAccount)
        
        assertIfScreenDoesNotExist(screenAccessibility: .createAccount)
    }
    
    func testNavigationToLogin() {
        
        launchAppToMenu()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .login)
        
        assertIfScreenDoesNotExist(screenAccessibility: .login)
    }
    
    func testNavigationToSendFeedback() {
        
        launchAppToMenu()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .sendFeedback)
        
        assertIfScreenDoesNotExist(screenAccessibility: .sendFeedback)
    }
    
    func testNavigationToReportABug() {
        
        launchAppToMenu()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .reportABug)
        
        assertIfScreenDoesNotExist(screenAccessibility: .reportABug)
    }
    
    func testNavigationToAskAQuestion() {
        
        launchAppToMenu()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .askAQuestion)
        
        assertIfScreenDoesNotExist(screenAccessibility: .askAQuestion)
    }
    
//    func testNavigationToLeaveAReview() {
//        
//        launchAppToMenu()
//
//        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .leaveAReview)
//
//        assertIfScreenDoesNotExist(screenAccessibility: .leaveAReview)
//    }
    
    func testNavigationToShareAStoryWithUs() {
        
        launchAppToMenu()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .shareAStoryWithUs)
        
        assertIfScreenDoesNotExist(screenAccessibility: .shareAStoryWithUs)
    }
    
//    func testNavigationToShareGodTools() {
//        
//        launchAppToMenu()
//
//        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .shareGodTools)
//
//        assertIfScreenDoesNotExist(screenAccessibility: .shareGodTools)
//    }
    
    func testNavigationToTermsOfUse() {
        
        launchAppToMenu()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .termsOfUse)
        
        assertIfScreenDoesNotExist(screenAccessibility: .termsOfUse)
    }
    
    func testNavigationToPrivacyPolicy() {
        
        launchAppToMenu()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .privacyPolicy)
        
        assertIfScreenDoesNotExist(screenAccessibility: .privacyPolicy)
    }
    
    func testNavigationToCopyrightInfo() {
        
        launchAppToMenu()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .copyrightInfo)
        
        assertIfScreenDoesNotExist(screenAccessibility: .copyrightInfo)
    }
}
