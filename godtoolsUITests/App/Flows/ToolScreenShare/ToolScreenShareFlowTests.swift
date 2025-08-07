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
        
        let toolSettingsButton = app.queryButton(buttonAccessibility: .toolSettings)
        
        XCTAssertTrue(toolSettingsButton.exists)
        
        toolSettingsButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .toolSettings)
        
        let shareScreenButton = app.queryDescendants(id: AccessibilityStrings.Button.shareScreen.id)
                
        guard let shareScreenButton = shareScreenButton else {
            XCTAssertNotNil(shareScreenButton, "Found nil element.")
            return
        }
        
        XCTAssertTrue(shareScreenButton.exists)
        
        shareScreenButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .toolScreenShareTutorial)
    }
    
    private func getContinueButtonFromToolScreenShareTutorial() -> XCUIElement {
        app.queryButton(buttonAccessibility: .continueForward, waitForExistence: 1)
    }
    
    private func assertIsLastPageWithGenerateQRCodeAndShareLinkButtons() {
        
        let generateQRCodeButton = app.queryButton(buttonAccessibility: .generateQRCode, waitForExistence: 1)
        
        let shareLinkButton = app.queryButton(buttonAccessibility: .shareLink, waitForExistence: 1)
        
        XCTAssertTrue(generateQRCodeButton.exists)
        
        XCTAssertTrue(shareLinkButton.exists)
    }
    
    func testInitialScreenIsToolScreenShare() {
        
        launchAppToToolScreenShare()
    }
    
    func testCloseButtonClosesBackToTool() {
        
        launchAppToToolScreenShare()
        
        let closeButton: XCUIElement = app.queryButton(buttonAccessibility: .close)
        
        XCTAssertTrue(closeButton.exists)
        
        closeButton.tap()
        
        assertIfScreenDoesNotExist(screenAccessibility: .tract)
    }
    
    func testSkipNavigatesToLastPageWithGenerateQRCodeAndShareLinkButtons() {
        
        launchAppToToolScreenShare()
        
        let skipButton: XCUIElement = app.queryButton(buttonAccessibility: .skip)
        
        XCTAssertTrue(skipButton.exists)
        
        skipButton.tap()
        
        assertIsLastPageWithGenerateQRCodeAndShareLinkButtons()
    }
    
    func testNavigationThroughToolScreenShareWithContinueButtonLandsOnLastPageWithGenerateQRCodeAndShareLinkButtons() {
        
        launchAppToToolScreenShare()
        
        var continueButton: XCUIElement = getContinueButtonFromToolScreenShareTutorial()
        
        while continueButton.exists {
            continueButton.tap()
            continueButton = getContinueButtonFromToolScreenShareTutorial()
        }
        
        assertIsLastPageWithGenerateQRCodeAndShareLinkButtons()
    }
}
