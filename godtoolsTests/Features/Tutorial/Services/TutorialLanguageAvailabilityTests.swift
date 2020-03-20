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
    
    /*
     
     // TODO: I can't write this test at the moment, for some reason when I create a Locale with identifier LanguageCode-ScriptCode_RegionCode, the script code is nil.
     // Need to look into why that is. ~Levi
     
    func testThatATutorialSupportingSimplifiedChineseIsAvailableForADeviceInSimplifiedChineseLanguage() {
        
        let simplifedChineseLocales = [
            Locale(identifier: "zh_Hans"),
            Locale(identifier: "zh_Hans_CN"),
            Locale(identifier: "zh_Hans_SG"),
            Locale(identifier: "zh_Hans_MO"),
            Locale(identifier: "zh_Hans_HK")
        ]
        
        let supportedLangauges = MockSupportedLanguages(
            languages: [
                Locale(identifier: "zh-Hans")
            ]
        )
        
        let tutorialLanuageAvailability = TutorialLanguageAvailability(supportedLanguages: supportedLangauges)
        
        for simplifiedChineseLanguage in simplifedChineseLocales {
            
            let tutorialShouldBeAvailable: Bool = true
                        
            XCTAssertEqual(tutorialLanuageAvailability.isAvailableInLanguage(locale: simplifiedChineseLanguage), tutorialShouldBeAvailable, "Chinese simplified language \(simplifiedChineseLanguage) is not available in the list of tutorial supported languages.")
        }
    }*/
}
