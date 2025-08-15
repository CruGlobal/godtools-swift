//
//  ChooseAppLanguageFlowTests.swift
//  godtoolsUITests
//
//  Created by Levi Eggert on 3/28/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import XCTest

class ChooseAppLanguageFlowTests: BaseFlowTests {
        
    private func launchApp() {
        
        super.launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/ui_tests/settings/app_languages",
            checkInitialScreenExists: .appLanguages
        )
    }
    
    func testInitialScreenIsAppLanguages() {
        
        launchApp()
    }
    
    func testTappingAppLanguageNavigatesToConfirmAppLanguage() {
        
        launchApp()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .appLanguageListItem, buttonQueryType: .firstMatching)
        
        assertIfScreenDoesNotExist(screenAccessibility: .confirmAppLanguage)
    }
}
