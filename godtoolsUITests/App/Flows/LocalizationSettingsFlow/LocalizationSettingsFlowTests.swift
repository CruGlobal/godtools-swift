//
//  LocalizationSettingsFlowTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import XCTest

class LocalizationSettingsFlowTests: BaseFlowTests {
       
    private func launchApp() {
        
        super.launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/ui_tests/settings/localization",
            checkInitialScreenExists: .localizationSettings
        )
    }
    
    func testInitialScreenIsLocalizationSettings() {
        
        launchApp()
        
        super.assertIfInitialScreenDoesntExist()
    }
}
