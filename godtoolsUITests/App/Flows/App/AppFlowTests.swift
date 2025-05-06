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
    
    static let defaultWaitForScreenExistence: TimeInterval = 2
    
    private func launchAppToDashboardFavorites() {
        
        super.launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/dashboard/favorites",
            checkInitialScreenExists: .dashboardFavorites
        )
    }
    
    func testInitialScreenIsDashboardFavorites() {
        
        launchAppToDashboardFavorites()
    }
    
    func testNavigationToMenu() {
        
        launchAppToDashboardFavorites()
        
        let menuButton = app.queryButton(buttonAccessibility: .dashboardMenu)
        
        XCTAssertTrue(menuButton.exists)
        
        menuButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .menu)
    }
}

// MARK: - Dashboard Tabs

extension AppFlowTests {
    
    private func tabToScreenInDashboard(tabAccessibility: AccessibilityStrings.Button, dashboardScreenAccessibility: AccessibilityStrings.Screen) {
        
        let tab = app.queryFirstButtonMatching(buttonAccessibility: tabAccessibility)
        
        XCTAssertTrue(tab.exists)
        
        tab.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: dashboardScreenAccessibility, waitForExistence: AppFlowTests.defaultWaitForScreenExistence)
    }
    
    private func tabToLessons() {
        
        tabToScreenInDashboard(tabAccessibility: .dashboardTabLessons, dashboardScreenAccessibility: .dashboardLessons)
    }
    
    private func tabToFavorites() {
        
        tabToScreenInDashboard(tabAccessibility: .dashboardTabFavorites, dashboardScreenAccessibility: .dashboardFavorites)
    }
    
    private func tabToTools() {
        
        tabToScreenInDashboard(tabAccessibility: .dashboardTabTools, dashboardScreenAccessibility: .dashboardTools)
    }
    
    func testLessonsTabTappedNavigatesToLessons() {
                
        launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/dashboard/favorites",
            checkInitialScreenExists: .dashboardFavorites
        )
                
        tabToLessons()
    }
    
    func testFavoritesTabTappedNavigatesToFavorites() {
        
        launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/dashboard/tools",
            checkInitialScreenExists: .dashboardTools
        )
                        
        tabToFavorites()
    }
    
    func testToolsTabTappedNavigatesToTools() {
        
        launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/dashboard/favorites",
            checkInitialScreenExists: .dashboardFavorites
        )
                
        tabToTools()
    }
}

// MARK: - Favorites

extension AppFlowTests {
    
    func testToolDetailsTappedFromAFavoritedToolOpensToolDetails() {
        
        launchAppToDashboardFavorites()
        
        tabToFavorites()
                
        let toolDetails = app.queryFirstButtonMatching(buttonAccessibility: .toolDetails)
        
        XCTAssertTrue(toolDetails.exists)
        
        toolDetails.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .toolDetails, waitForExistence: AppFlowTests.defaultWaitForScreenExistence)
    }
    
    func testToolDetailsNavigatesBackToFavoritesWhenOpenedFromFavorites() {
        
        launchAppToDashboardFavorites()
        
        tabToFavorites()
        
        let toolDetails = app.queryFirstButtonMatching(buttonAccessibility: .toolDetails)
        
        XCTAssertTrue(toolDetails.exists)
        
        toolDetails.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .toolDetails)
        
        let toolDetailsNavBack = app.queryButton(buttonAccessibility: .toolDetailsNavBack)
        
        XCTAssertTrue(toolDetailsNavBack.exists)
        
        toolDetailsNavBack.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .dashboardFavorites, waitForExistence: AppFlowTests.defaultWaitForScreenExistence)
    }
}

// MARK: - Tools

extension AppFlowTests {
    
    func testTappingToolsCategoryFilterOpensToolsCategoryFiltersList() {
        
        launchAppToDashboardFavorites()
        
        tabToTools()
        
        let toolsCategoryFilter = app.queryButton(buttonAccessibility: .toolsCategoryFilter)
        
        XCTAssertTrue(toolsCategoryFilter.exists)
        
        toolsCategoryFilter.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .toolsCategoryFilters)
    }
    
    func testTappingToolsLanguageFilterOpensToolsLanguageFiltersList() {
        
        launchAppToDashboardFavorites()
        
        tabToTools()
        
        let toolsLanguageFilter = app.queryButton(buttonAccessibility: .toolsLanguageFilter)
        
        XCTAssertTrue(toolsLanguageFilter.exists)
        
        toolsLanguageFilter.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .toolsLanguageFilters)
    }
    
    func testTappingSpotlightToolFromToolsOpensToolDetails() {
        
        launchAppToDashboardFavorites()
        
        tabToTools()
        
        let spotlightTool = app.queryDescendants(id: AccessibilityStrings.Button.spotlightTool.id)
        
        guard let spotlightTool = spotlightTool else {
            XCTAssertNotNil(spotlightTool, "Found nil element.")
            return
        }
        
        XCTAssertTrue(spotlightTool.exists)
        
        spotlightTool.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .toolDetails)
    }
    
    func testTappingToolFromToolsOpensToolDetails() {
        
        launchAppToDashboardFavorites()
        
        tabToTools()
        
        let tool = app.queryDescendants(id: AccessibilityStrings.Button.tool.id)
        
        guard let tool = tool else {
            XCTAssertNotNil(tool, "Found nil element.")
            return
        }

        XCTAssertTrue(tool.exists)
        
        tool.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .toolDetails)
    }
}
