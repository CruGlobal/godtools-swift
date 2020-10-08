//
//  LocaleTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 10/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

import XCTest
@testable import godtools

class LocaleTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testThatLocalesAreEqual() {
        
        let locale_A = Locale(identifier: "en_US")
        let locale_B = Locale(identifier: "en-US")
        
        XCTAssert(locale_A.isEqualTo(locale: locale_B), "")
    }
    
    func testThatLocalesAreNotEqual() {
        
        let english = Locale(identifier: "en")
        let english_US = Locale(identifier: "en_US")
        
        XCTAssert(!english.isEqualTo(locale: english_US), "")
    }
    
    func testThatLocaleBaseLanguagesAreEqual() {
        
        let localeIds: [String] = ["zh", "zh-Hans", "zh-Hant", "zh_Hans", "zh_Hant"]
        
        for thisId in localeIds {
            
            let locale = Locale(identifier: thisId)
            
            for thatId in localeIds {
                
                let thatLocale = Locale(identifier: thatId)
                
                XCTAssert(locale.baseLanguageIsEqualToLocaleBaseLanguage(locale: thatLocale), "")
            }
        }
    }
    
    func testThatZHHansIsTheOnlyNonBaseLanguage() {
        
        let zh_Hans_Id = "zh-Hans"
        
        var localeIds: [String] = ["zh", "en", "es", "fr"]
        
        localeIds.append(zh_Hans_Id)
        
        for id in localeIds {
            
            let locale = Locale(identifier: id)
                            
            let languageIsNotABaseLanguageAndLanguageIsNotZHHans: Bool = !locale.isBaseLanguage && id != zh_Hans_Id
                  
            if languageIsNotABaseLanguageAndLanguageIsNotZHHans {
                XCTAssertFalse(languageIsNotABaseLanguageAndLanguageIsNotZHHans, "")
            }
        }
    }
}
