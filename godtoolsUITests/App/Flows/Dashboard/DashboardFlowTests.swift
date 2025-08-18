//
//  DashboardFlowTests.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import XCTest

class DashboardFlowTests: BaseFlowTests {
        
    private func launchAppToDashboardFavorites() {
        
        super.launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/dashboard/favorites",
            checkInitialScreenExists: .dashboardFavorites
        )
    }
    
    private func launchAppToDashboardTools() {
        
        super.launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/dashboard/tools",
            checkInitialScreenExists: .dashboardTools
        )
    }
    
    func testInitialScreenIsDashboardFavorites() {
        
        launchAppToDashboardFavorites()
    }
    
    func testNavigationToMenu() {
        
        launchAppToDashboardFavorites()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .dashboardMenu)
        
        assertIfScreenDoesNotExist(screenAccessibility: .menu)
    }
}

// MARK: - Dashboard Tabs

extension DashboardFlowTests {
    
    private func tabToScreenInDashboard(tabAccessibility: AccessibilityStrings.Button, dashboardScreenAccessibility: AccessibilityStrings.Screen) {
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: tabAccessibility, buttonQueryType: .firstMatch)
        
        assertIfScreenDoesNotExist(screenAccessibility: dashboardScreenAccessibility)
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

extension DashboardFlowTests {
    
    func testToolDetailsTappedFromAFavoritedToolOpensToolDetails() {
        
        launchAppToDashboardFavorites()
        
        tabToFavorites()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .toolDetails, buttonQueryType: .firstMatch)
        
        assertIfScreenDoesNotExist(screenAccessibility: .toolDetails)
    }
    
    func testToolDetailsNavigatesBackToFavoritesWhenOpenedFromFavorites() {
        
        launchAppToDashboardFavorites()
        
        tabToFavorites()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .toolDetails, buttonQueryType: .firstMatch)
        
        assertIfScreenDoesNotExist(screenAccessibility: .toolDetails)
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .toolDetailsNavBack)
        
        assertIfScreenDoesNotExist(screenAccessibility: .dashboardFavorites)
    }
}

// MARK: - Tools

extension DashboardFlowTests {
    
    func testTappingToolsCategoryFilterOpensToolsCategoryFiltersList() {
        
        launchAppToDashboardTools()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .toolsCategoryFilter)
        
        assertIfScreenDoesNotExist(screenAccessibility: .toolsCategoryFilters)
    }
    
    func testTappingToolsLanguageFilterOpensToolsLanguageFiltersList() {
        
        launchAppToDashboardTools()
                
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .toolsLanguageFilter)
        
        assertIfScreenDoesNotExist(screenAccessibility: .toolsLanguageFilters)
    }
    
    func testTappingSpotlightToolFromToolsOpensToolDetails() {
        
        launchAppToDashboardTools()
        
        let spotlightToolId: String = AccessibilityStrings.Button.getToolButtonAccessibility(
            toolButton: .spotlightTool,
            toolName: .teachMeToShare
        )
        
        assertIfButtonDoesNotExistElseTap(buttonId: spotlightToolId, buttonQueryType: .searchDescendants)
        
        assertIfScreenDoesNotExist(screenAccessibility: .toolDetails)
    }
    
    func testTappingToolFromToolsOpensToolDetails() {
        
        launchAppToDashboardTools()
        
        let toolId: String = AccessibilityStrings.Button.getToolButtonAccessibility(
            toolButton: .tool,
            toolName: .fourSpiritualLaws
        )
        
        assertIfButtonDoesNotExistElseTap(buttonId: toolId, buttonQueryType: .searchDescendants)
        
        assertIfScreenDoesNotExist(screenAccessibility: .toolDetails)
    }
}
