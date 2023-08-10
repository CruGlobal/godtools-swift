//
//  LocalizableStringsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 8/9/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import XCTest
@testable import godtools

class LocalizableStringsRepositoryTests: XCTestCase {
        
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private func newStringsRepository(fileType: LocalizableStringsFileType) -> LocalizableStringsRepository {
        
        return LocalizableStringsRepository(
            localizableStringsBundleLoader: LocalizableStringsBundleLoader(localizableStringsFilesBundle: Bundle.main),
            fileType: fileType
        )
    }
    
    // MARK: - English
    
    func testStringInEnglishLocalizableStringsExists() {
                
        let localizedString: String? = newStringsRepository(fileType: .strings).stringForEnglish(key: "yes")
        
        XCTAssertNotNil(localizedString)
        XCTAssertEqual(localizedString, "Yes")
    }
    
    func testStringInEnglishLocalizableStringsdictExists() {
                
        let localizedString: String? = newStringsRepository(fileType: .stringsdict).stringForEnglish(key: "badges.toolsOpened")
        
        XCTAssertNotNil(localizedString)
    }
    
    // MARK: - String For Locale
    
    func testStringInSpanishLocalizableStringsExists() {
        
        let localizedString: String? = newStringsRepository(fileType: .strings).stringForLocale(localeIdentifier: "es", key: "yes")
        
        XCTAssertNotNil(localizedString)
        XCTAssertEqual(localizedString, "Sí")
    }
    
    func testStringForLocaleDoesNotExist() {
        
        let localizedString: String? = newStringsRepository(fileType: .strings).stringForLocale(localeIdentifier: LocalizableStringsBundleLoaderTests.invalidLocalizableStringsResource, key: "yes")
        
        XCTAssertNil(localizedString)
    }
    
    func testStringForLocaleFallsBackToEnglish() {
        
        let localizedString: String? = newStringsRepository(fileType: .strings).stringForLocaleElseEnglish(localeIdentifier: LocalizableStringsBundleLoaderTests.invalidLocalizableStringsResource, key: "yes")
        
        XCTAssertNotNil(localizedString)
        XCTAssertEqual(localizedString, "Yes")
    }
    
    func testStringForLocaleFallsBackToSystemElseEnglish() {
        
        let localizedString: String? = newStringsRepository(fileType: .strings).stringForLocaleElseSystemElseEnglish(localeIdentifier: LocalizableStringsBundleLoaderTests.invalidLocalizableStringsResource, key: "yes")
        
        XCTAssertNotNil(localizedString)
    }
}
