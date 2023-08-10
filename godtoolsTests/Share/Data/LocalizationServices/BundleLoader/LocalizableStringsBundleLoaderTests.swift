//
//  LocalizableStringsBundleLoaderTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 8/9/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import XCTest
@testable import godtools

class LocalizableStringsBundleLoaderTests: XCTestCase {
    
    static let invalidLocalizableStringsResource: String = "es-419"
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private func newBundleLoader() -> LocalizableStringsBundleLoader {
        
        return LocalizableStringsBundleLoader(localizableStringsFilesBundle: Bundle.main)
    }
    
    func testLoadingEnglishLocalizableStringsBundleExists() {
        
        let englishStringsBundle: LocalizableStringsBundle? = newBundleLoader().getEnglishBundle(fileType: .strings)
        
        XCTAssertNotNil(englishStringsBundle)
    }
    
    func testLoadingEnglishLocalizableStringsdictBundleExists() {
        
        let englishStringsdictBundle: LocalizableStringsBundle? = newBundleLoader().getEnglishBundle(fileType: .stringsdict)
        
        XCTAssertNotNil(englishStringsdictBundle)
    }
    
    func testLoadingSpanishLocalizableStringsBundleExists() {
        
        let spanishStringsBundle: LocalizableStringsBundle? = newBundleLoader().bundleForResource(resourceName: "es", fileType: .strings)
        
        XCTAssertNotNil(spanishStringsBundle)
    }
    
    func testLoadingSpanishLocalizableStringsdictBundleExists() {
        
        let spanishStringsdictBundle: LocalizableStringsBundle? = newBundleLoader().bundleForResource(resourceName: "es", fileType: .stringsdict)
        
        XCTAssertNotNil(spanishStringsdictBundle)
    }
    
    func testLoadingLocalizableStringsBundleDoesNotExist() {
        
        let spanishStringsBundle: LocalizableStringsBundle? = newBundleLoader().bundleForResource(resourceName: LocalizableStringsBundleLoaderTests.invalidLocalizableStringsResource, fileType: .strings)
        
        XCTAssertNil(spanishStringsBundle)
    }
    
    func testLoadingLocalizableStringsdictBundleDoesNotExist() {
        
        let spanishStringsdictBundle: LocalizableStringsBundle? = newBundleLoader().bundleForResource(resourceName: LocalizableStringsBundleLoaderTests.invalidLocalizableStringsResource, fileType: .stringsdict)
        
        XCTAssertNil(spanishStringsdictBundle)
    }
}
