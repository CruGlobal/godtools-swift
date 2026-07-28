//
//  LocalizationSettingsFlowTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import XCTest

final class LocalizationSettingsFlowTests: BaseFlowTests {
       
    private func launchApp() {
        
        super.launchApp(
            flowDeepLinkUrl: DeepLinkUrl.getSettingsLocalization(),
            checkInitialScreenExists: .localizationSettings
        )
    }
    
    func testInitialScreenIsLocalizationSettings() {
        
        launchApp()
        
        super.assertIfInitialScreenDoesntExist()
    }
    
    func testTappingLocalizationSettingsCountryNavigatesToConfirmLocalizationSettings() {
        
        launchApp()
                
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .localizationSettingsCountryListItem, buttonQueryType: .firstMatch)
        
        assertIfScreenDoesNotExist(screenAccessibility: .confirmLocalizationSettings)
    }
    
    func testTappingEditLocalizationFromConfirmLocalizationSettingsNavigatesBackToLocalizationSettings() {
        
        launchApp()
                
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .localizationSettingsCountryListItem, buttonQueryType: .firstMatch)
        
        assertIfScreenDoesNotExist(screenAccessibility: .confirmLocalizationSettings)
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .editLocalization)
        
        assertIfScreenDoesNotExist(screenAccessibility: .localizationSettings)
    }
}
