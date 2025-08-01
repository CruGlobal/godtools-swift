//
//  LearnToShareToolFlowTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import XCTest
@testable import godtools

class LearnToShareToolFlowTests: BaseFlowTests {
    
    private func launchAppToDashboardTools() {
        
        super.launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/dashboard/tools",
            checkInitialScreenExists: .dashboardTools
        )
    }
    
    private func openToolToToolDetails(toolName: String) {
        
        let teachMeToShare = app.queryDescendants(id: AccessibilityStrings.Button.tool.rawValue + " " + toolName)
        
        guard let teachMeToShare = teachMeToShare else {
            XCTAssertNotNil(teachMeToShare, "Found nil element.")
            return
        }

        XCTAssertTrue(teachMeToShare.exists)
        
        teachMeToShare.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .toolDetails)
    }
    
    private func openToolToToolDetailsAndNavigateToLearnToShareFlow(toolName: String) {
        
        openToolToToolDetails(toolName: toolName)
        
        let learnToShareButton = getLearnToShareButtonFromToolDetails()
        
        XCTAssertTrue(learnToShareButton.exists)
                
        learnToShareButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .learnToShareTool)
    }
    
    private func getLearnToShareButtonFromToolDetails() -> XCUIElement {
        return app.queryButton(buttonAccessibility: .learnToShare)
    }
    
    private func getContinueButtonFromLearnToShare() -> XCUIElement {
        app.queryButton(buttonAccessibility: .continueForward, waitForExistence: 1)
    }
    
    func testInitialScreenIsDashboardTools() {
        
        launchAppToDashboardTools()
    }
    
    func testTappingLearnToShareFromToolDetailsNavigatesToLearnToShareFlow() {
        
        launchAppToDashboardTools()
                
        openToolToToolDetailsAndNavigateToLearnToShareFlow(toolName: ToolNames.English.fourSpiritualLaws)
    }
    
    func testTappingCloseLearnToShareOpensTool() {
        
        launchAppToDashboardTools()
                
        openToolToToolDetailsAndNavigateToLearnToShareFlow(toolName: ToolNames.English.fourSpiritualLaws)
        
        let closeButton: XCUIElement = app.queryButton(buttonAccessibility: .close)
        
        XCTAssertTrue(closeButton.exists)
        
        closeButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .tract)
    }
    
    func testNavigationThroughLearnToShareOpensToolWhenStartTrainingIsTapped() {
        
        launchAppToDashboardTools()
                
        openToolToToolDetailsAndNavigateToLearnToShareFlow(toolName: ToolNames.English.fourSpiritualLaws)
        
        var continueButton: XCUIElement = getContinueButtonFromLearnToShare()
        
        while continueButton.exists {
            continueButton.tap()
            continueButton = getContinueButtonFromLearnToShare()
        }
        
        let startTrainingButton = app.queryButton(buttonAccessibility: .startTraining, waitForExistence: 1)
        
        XCTAssertTrue(startTrainingButton.exists)
                
        startTrainingButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .tract)
    }
}
