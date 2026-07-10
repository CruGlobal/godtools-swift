//
//  TutorialFlowTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import XCTest

class TutorialFlowTests: BaseFlowTests {
        
    private func launchApp() {
        
        super.launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/ui_tests/tutorial",
            checkInitialScreenExists: .tutorial
        )
    }
    
    func testInitialScreenIsTutorial() {
        
        launchApp()
        
        super.assertIfInitialScreenDoesntExist()
    }
}
