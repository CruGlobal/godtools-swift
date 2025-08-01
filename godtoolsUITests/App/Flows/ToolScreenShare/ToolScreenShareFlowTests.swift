//
//  ToolScreenShareFlowTests.swift
//  godtools
//
//  Created by Levi Eggert on 8/1/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import XCTest
@testable import godtools

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
    }
    
    func testInitialScreenIsToolScreenShare() {
        
        launchAppToToolScreenShare()
    }
}
