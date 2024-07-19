//
//  AppFlowTests.swift
//  godtoolsUITests
//
//  Created by Levi Eggert on 7/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import XCTest
@testable import godtools

class AppFlowTests: BaseFlowTests {
    
    private func launchApp() {
        
        super.launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/dashboard/favorites",
            initialScreen: .dashboardFavorites
        )
    }
    
    func testInitialScreenIsDashboardFavorites() {
        
        launchApp()
        
        super.checkInitialScreenExists(app: app)
    }
    
    func testNavigationToMenu() {
        
        launchApp()
        
        let menuButton = app.queryButton(buttonAccessibility: .dashboardMenu)
        
        XCTAssertTrue(menuButton.exists)
        
        menuButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .menu)
    }
    
    private func getDashboardTabButton(buttonAccessibility: AccessibilityStrings.Button) -> XCUIElement {
                
        return app.queryButton(buttonAccessibility: buttonAccessibility).firstMatch
    }
    
    private func navigateToLessons() {
        
        let lessonsTab = getDashboardTabButton(buttonAccessibility: .dashboardTabLessons)
        
        XCTAssertTrue(lessonsTab.exists)
        
        lessonsTab.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .dashboardLessons)
    }
    
    private func navigateToFavorites() {
        
        let favoritesTab = getDashboardTabButton(buttonAccessibility: .dashboardTabFavorites)
        
        XCTAssertTrue(favoritesTab.exists)
        
        favoritesTab.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .dashboardFavorites)
    }
    
    private func navigateToTools() {
        
        let toolsTab = getDashboardTabButton(buttonAccessibility: .dashboardTabTools)
        
        XCTAssertTrue(toolsTab.exists)
        
        toolsTab.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .dashboardTools)
    }
    
    func testLessonsTabTappedNavigatesToLessons() {
        
        launchApp()
        
        navigateToLessons()
    }
    
    func testFavoritesTabTappedNavigatesToFavorites() {
        
        launchApp()
        
        navigateToFavorites()
    }
    
    func testToolsTabTappedNavigatesToTools() {
        
        launchApp()
        
        navigateToTools()
    }
    
    func testToolDetailsTappedFromFavoritedToolOpensToolDetails() {
        
        launchApp()
        
        navigateToFavorites()
        
        let toolDetails = app.queryButton(buttonAccessibility: .toolDetails).firstMatch
        
        XCTAssertTrue(toolDetails.exists)
        
        toolDetails.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .toolDetails)
    }
    
    func testToolDetailsNavigatesBackToFavoritesWhenOpenedFromFavorites() {
        
        launchApp()
        
        navigateToFavorites()
        
        let toolDetails = app.queryButton(buttonAccessibility: .toolDetails).firstMatch
        
        XCTAssertTrue(toolDetails.exists)
        
        toolDetails.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .toolDetails)
        
        let toolDetailsNavBack = app.queryButton(buttonAccessibility: .toolDetailsNavBack)
        
        XCTAssertTrue(toolDetailsNavBack.exists)
        
        toolDetailsNavBack.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .dashboardFavorites)
    }
}
