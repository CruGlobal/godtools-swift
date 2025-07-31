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
    
    private func getLearnToShareButton() -> XCUIElement {
        return app.queryButton(buttonAccessibility: .learnToShare)
    }
    
    func testInitialScreenIsDashboardFavorites() {
        
        launchAppToDashboardTools()
    }
    
    func testTappingLearnToShare() {
        
        launchAppToDashboardTools()
                
        openToolToToolDetails(toolName: ToolNames.English.fourSpiritualLaws)
        
        let learnToShareButton = getLearnToShareButton()
        
        XCTAssertTrue(learnToShareButton.exists)
                
        learnToShareButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .learnToShareTool)
    }
}
