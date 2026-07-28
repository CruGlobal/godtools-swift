//
//  ChooseAppLanguageFlowTests.swift
//  godtoolsUITests
//
//  Created by Levi Eggert on 3/28/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import XCTest

final class ChooseAppLanguageFlowTests: BaseFlowTests {
        
    private func launchApp() {
        
        super.launchApp(
            flowDeepLinkUrl: DeepLinkUrl.getSettingsAppLanguages(),
            checkInitialScreenExists: .appLanguages
        )
    }
    
    func testInitialScreenIsAppLanguages() {
        
        launchApp()
    }
    
    func testTappingAppLanguageNavigatesToConfirmAppLanguage() {
        
        launchApp()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .appLanguageListItem, buttonQueryType: .firstMatch)
        
        assertIfScreenDoesNotExist(screenAccessibility: .confirmAppLanguage)
        
        assertIfButtonDoesNotExist(buttonAccessibility: .nevermind)
        
        assertIfButtonDoesNotExist(buttonAccessibility: .changeLanguage)
    }
    
    func testTappingNevermindFromConfirmAppLanguageNavigatesToChooseAppLanguage() {
        
        launchApp()
                
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .appLanguageListItem, buttonQueryType: .firstMatch)
        
        assertIfScreenDoesNotExist(screenAccessibility: .confirmAppLanguage)
                
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .nevermind)
        
        assertIfScreenDoesNotExist(screenAccessibility: .appLanguages)
    }
}
