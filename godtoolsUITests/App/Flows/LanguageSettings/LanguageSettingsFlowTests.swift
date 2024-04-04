//
//  LanguageSettingsFlowTests.swift
//  godtoolsUITests
//
//  Created by Levi Eggert on 3/28/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import XCTest
@testable import godtools

class LanguageSettingsFlowTests: BaseFlowTests {
        
    private func launchApp() {
        
        super.launchApp(
            flowDeepLinkUrl: "godtools://org.cru.godtools/ui_tests/settings/language",
            initialScreen: .languageSettings
        )
    }
    
    private func getChooseAppLanguageButton(app: XCUIApplication) -> XCUIElement {
        return app.queryButton(buttonAccessibility: .chooseAppLanguage)
    }
    
    private func getEditDownloadedLanguagesButton(app: XCUIApplication) -> XCUIElement {
        return app.queryButton(buttonAccessibility: .editDownloadedLanguages)
    }
    
    // MARK: - Tests
    
    func testInitialScreenIsLanguageSettings() {
        
        launchApp()
        
        super.checkInitialScreenExists(app: app)
    }
    
    func testNavigationToAppLanguagesList() {
        
        launchApp()
        
        let chooseAppLanguageButton = getChooseAppLanguageButton(app: app)
        
        XCTAssertTrue(chooseAppLanguageButton.exists)
        
        chooseAppLanguageButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .appLanguages)
    }
    
    func testNavigationToDownloadableLanguagesList() {
        
        launchApp()
        
        let editDownloadedLanguagesButton = getEditDownloadedLanguagesButton(app: app)
        
        XCTAssertTrue(editDownloadedLanguagesButton.exists)
        
        editDownloadedLanguagesButton.tap()
        
        assertIfScreenDoesNotExist(app: app, screenAccessibility: .downloadableLanguages)
    }
}
