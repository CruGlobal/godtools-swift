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
    
    private func launchAppToTeachMeToShareTool() {
        
        super.launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/tool/tract/teachmetoshare/en",
            checkInitialScreenExists: .tract
        )
    }
    
    func testInitialScreenIsTeachMeToShareTool() {
        
        launchAppToTeachMeToShareTool()
    }
}
