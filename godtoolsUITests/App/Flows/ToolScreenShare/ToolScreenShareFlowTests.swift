//
//  ToolScreenShareFlowTests.swift
//  godtools
//
//  Created by Levi Eggert on 8/1/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import XCTest

class ToolScreenShareFlowTests: BaseFlowTests {
    
    private func launchAppToToolScreenShare() {
        
        super.launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/tool/tract/teachmetoshare/en",
            checkInitialScreenExists: .tract
        )
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .toolSettings)
        
        assertIfScreenDoesNotExist(screenAccessibility: .toolSettings)
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .shareScreen, buttonQueryType: .searchDescendants)
        
        assertIfScreenDoesNotExist(screenAccessibility: .toolScreenShareTutorial)
    }
    
    private func assertIsLastPageWithGenerateQRCodeAndShareLinkButtons() {
        
        assertIfButtonDoesNotExist(buttonAccessibility: .generateQRCode)
        
        assertIfButtonDoesNotExist(buttonAccessibility: .shareLink)
    }
    
    func testInitialScreenIsToolScreenShare() {
        
        launchAppToToolScreenShare()
    }
    
    func testCloseButtonClosesBackToTool() {
        
        launchAppToToolScreenShare()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .close)
        
        assertIfScreenDoesNotExist(screenAccessibility: .tract)
    }
    
    func testSkipNavigatesToLastPageWithGenerateQRCodeAndShareLinkButtons() {
        
        launchAppToToolScreenShare()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .skip)
        
        assertIsLastPageWithGenerateQRCodeAndShareLinkButtons()
    }
    
    func testNavigationThroughToolScreenShareWithContinueButtonLandsOnLastPageWithGenerateQRCodeAndShareLinkButtons() {
        
        launchAppToToolScreenShare()
        
        tapWhileExists(buttonAccessibility: .continueForward)
        
        assertIsLastPageWithGenerateQRCodeAndShareLinkButtons()
    }
}
