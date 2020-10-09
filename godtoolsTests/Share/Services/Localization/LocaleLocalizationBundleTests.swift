//
//  LocaleLocalizationBundleTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 10/5/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import XCTest
@testable import godtools

class LocaleLocalizationBundleTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testThatAllLocalizationsAreLoaded() {
                
        let localizations: [String] = Bundle.main.localizations
        let bundleLoader = LocalizationBundleLoader()
                
        for localeIdentifier in localizations {
                        
            let localeLocalizationBundle = LocaleLocalizationBundle(
                localeIdentifier: localeIdentifier,
                bundleLoader: bundleLoader
            )
                        
            XCTAssertNotNil(localeLocalizationBundle.localeBundle, "Failed to load locale bundle for localeIdentifier: \(localeIdentifier)")
        }
    }
}
