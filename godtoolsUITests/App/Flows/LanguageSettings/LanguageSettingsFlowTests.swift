//
//  LanguageSettingsFlowTests.swift
//  godtoolsUITests
//
//  Created by Levi Eggert on 3/28/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import XCTest

final class LanguageSettingsFlowTests: BaseFlowTests {
        
    private func launchApp() {
        
        super.launchApp(
            flowDeepLinkUrl: DeepLinkUrl.getSettingsLanguage(),
            checkInitialScreenExists: .languageSettings
        )
    }
    
    func testInitialScreenIsLanguageSettings() {
        
        launchApp()
        
        super.assertIfInitialScreenDoesntExist()
    }
    
    func testNavigationToAppLanguagesList() {
        
        launchApp()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .chooseAppLanguage)
        
        assertIfScreenDoesNotExist(screenAccessibility: .appLanguages)
    }
    
    func testNavigationToDownloadableLanguagesList() {
        
        launchApp()
        
        assertIfButtonDoesNotExistElseTap(buttonAccessibility: .editDownloadedLanguages)
        
        assertIfScreenDoesNotExist(screenAccessibility: .downloadableLanguages)
    }
}
