//
//  LearnToShareToolFlowTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import XCTest

class LearnToShareToolFlowTests: BaseFlowTests {
    
    private func launchAppToToolDetails() {
        
        super.launchApp(
            flowDeepLinkUrl: DeepLinkUrl.getToolDetails(toolId: "ui_test_resource_2"),
            checkInitialScreenExists: .toolDetails
        )
    }

    private func navigateToLearnToShareFromToolsDetails() {
                
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .learnToShare)
        
        assertIfScreenDoesNotExist(screenAccessibility: .learnToShareTool)
    }
    
    func testInitialScreenIsToolDetails() {
        
        launchAppToToolDetails()
    }
    
    func testTappingLearnToShareFromToolDetailsNavigatesToLearnToShareFlow() {
        
        launchAppToToolDetails()
        
        navigateToLearnToShareFromToolsDetails()
    }
    
    func testTappingCloseLearnToShareNavigatesToTheTool() {
        
        launchAppToToolDetails()
        
        navigateToLearnToShareFromToolsDetails()
                
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .close)
        
        assertIfScreenDoesNotExist(screenAccessibility: .tract)
    }
    
    func testNavigationThroughLearnToShareOpensToolWhenStartTrainingIsTapped() {
        
        launchAppToToolDetails()
        
        navigateToLearnToShareFromToolsDetails()
        
        tapWhileExists(buttonAccessibility: .continueForward)
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .startTraining)
                
        assertIfScreenDoesNotExist(screenAccessibility: .tract)
    }
}
