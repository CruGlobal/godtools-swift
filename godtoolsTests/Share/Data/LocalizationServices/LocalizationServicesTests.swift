//
//  LocalizationServicesTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 8/9/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import XCTest
@testable import godtools

class LocalizationServicesTests: XCTestCase {
    
    private let invalidLocalizableStringsKey: String = UUID().uuidString
    
    private lazy var localizationServices: LocalizationServices = {
        return LocalizationServices(localizableStringsFilesBundle: Bundle.main)
    }()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testStringInEnglishLocalizableStringsExists() {
                
        let localizedString: String? = localizationServices.stringForEnglish(key: "yes", fileType: .strings)
        
        XCTAssertNotNil(localizedString)
        XCTAssertEqual(localizedString, "Yes")
    }
    
    func testStringInEnglishLocalizableStringsdictExists() {
                
        let localizedString: String? = localizationServices.stringForEnglish(key: "badges.toolsOpened", fileType: .stringsdict)
        
        XCTAssertNotNil(localizedString)
    }
    
    func testMissingStringInEnglishLocalizableStringsdictReturnsKeyValue() {
                
        let invalidKeyValue: String = "yes"
        let localizedString: String = localizationServices.stringForEnglish(key: invalidKeyValue, fileType: .stringsdict)
        
        XCTAssertEqual(localizedString, invalidKeyValue)
    }
    
    func testMissingStringInLocalizableStringsReturnsKeyValue() {
        
        let invalidLocalizableStringsResource: String = LocalizableStringsBundleLoaderTests.invalidLocalizableStringsResource
        let invalidKeyValue: String = invalidLocalizableStringsKey
        
        let missingStringForEnglish: String = localizationServices.stringForEnglish(key: invalidKeyValue)
        let missingStringForSystemElseEnglish: String = localizationServices.stringForSystemElseEnglish(key: invalidKeyValue)
        let missingStringForLocaleElseEnglish: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: invalidLocalizableStringsResource, key: invalidKeyValue)
        let missingStringForLocaleElseSystemElseEnglish: String = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: invalidLocalizableStringsResource, key: invalidKeyValue)
        
        XCTAssertEqual(missingStringForEnglish, invalidKeyValue)
        XCTAssertEqual(missingStringForSystemElseEnglish, invalidKeyValue)
        XCTAssertEqual(missingStringForLocaleElseEnglish, invalidKeyValue)
        XCTAssertEqual(missingStringForLocaleElseSystemElseEnglish, invalidKeyValue)
    }
}
