//
//  LanguageTests.swift
//  godtoolsTests
//
//  Created by Dean Thibault on 8/6/19.
//  Copyright © 2019 Cru. All rights reserved.
//

import XCTest
@testable import godtools

let testLanguageCode = "fa"
let testLanguageName = "This is a test Language"
let invalidLanguageCode = "xyz"

class LanguageTests: XCTestCase {

    // Validate that correct lanuage name string is retrieved from Localizable.strings
    func testFromTranslation() {
        let lang = Language()
        lang.code = testLanguageCode
        
        let testName = testLanguageCode.localized
        let testResult = lang.localizedName(locale: NSLocale.current, table: "Localizable")
        
        XCTAssertEqual(testResult, testName)
    }
    
    // Validate correct lanague name string is retrieved from Locale, when code is not in Localizable.strings
    func testFromLocale() {
        let lang = Language()
        lang.code = testLanguageCode
        
        let testName = "Persian".localized
        let testResult = lang.localizedName(locale: NSLocale.current, table: "DoesntExist")
        
        XCTAssertEqual(testResult, testName)
    }

    // Validate defailt lanague name string is retrieved from Language, when code is not found in Locale or Localizable.strings
    func testDefaultFromLanguage() {
        let lang = Language()
        lang.code = testLanguageCode
        lang.code = testLanguageName

        let testLocale = Locale(identifier: invalidLanguageCode)
        
        let testResult = lang.localizedName(locale: testLocale, table: "DoesntExist")
        
        XCTAssertEqual(testResult, testLanguageName)
    }
    
    // Validate lanague name code string is returned, when translation not found
    func testInvalidCode() {
        let lang = Language()
        lang.code = invalidLanguageCode
        
        let testResult = lang.localizedName(locale: NSLocale.current, table: "DoesntExist")
        
        XCTAssertEqual(testResult, invalidLanguageCode)
    }
}
