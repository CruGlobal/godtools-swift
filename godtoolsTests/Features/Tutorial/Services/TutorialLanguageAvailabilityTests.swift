//
//  TutorialLanguageAvailabilityTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import XCTest
@testable import godtools

class TutorialLanguageAvailabilityTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testThatATutorialSupportingEnglishIsAvailableForADeviceEnglishLanguage() {
        
        let deviceEnglishLanguage: Locale = Locale(identifier: "en")
        
        let supportedLangauges = MockSupportedLanguages(
            languages: [
                Locale(identifier: "en"),
                Locale(identifier: "es"),
                Locale(identifier: "da"),
                Locale(identifier: "ps"),
                Locale(identifier: "ss_SZ"),
                Locale(identifier: "ln")
            ]
        )
        
        let tutorialLanguageAvailability = TutorialLanguageAvailability(supportedLanguages: supportedLangauges)
        
        let tutorialShouldBeAvailable: Bool = true
        
        XCTAssertEqual(tutorialLanguageAvailability.isAvailableInLanguage(locale: deviceEnglishLanguage), tutorialShouldBeAvailable)
    }
          
    func testThatATutorialSupportingSimplifiedChineseIsAvailableForADeviceInSimplifiedChineseLanguage() {
        
        let simplifedChineseLocales = [
            Locale(identifier: "zh_Hans"),
            Locale(identifier: "zh-Hans-CN"),
            Locale(identifier: "zh-Hans-SG"),
            Locale(identifier: "zh-Hans-MO"),
            Locale(identifier: "zh-Hans-HK")
        ]
        
        let supportedLangauges = MockSupportedLanguages(
            languages: [
                Locale(identifier: "zh-Hans")
            ]
        )
        
        let tutorialLanuageAvailability = TutorialLanguageAvailability(supportedLanguages: supportedLangauges)
        
        for simplifiedChineseLanguage in simplifedChineseLocales {
            
            let tutorialShouldBeAvailable: Bool = true
                        
            XCTAssertEqual(tutorialLanuageAvailability.isAvailableInLanguage(locale: simplifiedChineseLanguage), tutorialShouldBeAvailable, "Chinese simplified language \(simplifiedChineseLanguage) should be available in the supported simplified chinese language.")
        }
    }
    
    func testThatATutorialSupportingSimplifiedChineseIsNotAvailableForADeviceInTraditionalChineseLanguage() {
        
        let traditionalChineseLocales = [
            Locale(identifier: "zh"),
            Locale(identifier: "zh-Hant"),
            Locale(identifier: "zh-Hant-CN"),
            Locale(identifier: "zh-Hant-TW"),
            Locale(identifier: "zh-Hant-MO"),
            Locale(identifier: "zh-Hant-HK")
        ]
        
        let supportedLangauges = MockSupportedLanguages(
            languages: [
                Locale(identifier: "zh-Hans")
            ]
        )
        
        let tutorialLanuageAvailability = TutorialLanguageAvailability(supportedLanguages: supportedLangauges)
        
        for traditionalChineseLanguage in traditionalChineseLocales {
            
            let tutorialShouldBeAvailable: Bool = false
                        
            XCTAssertEqual(tutorialLanuageAvailability.isAvailableInLanguage(locale: traditionalChineseLanguage), tutorialShouldBeAvailable, "Chinese traditional language \(traditionalChineseLanguage) should not be available in the supported simplified chinese language.")
        }
    }
}
