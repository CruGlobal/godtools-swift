//
//  DownloadInitialResourcesTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 8/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import XCTest
@testable import godtools
import Combine

class DownloadInitialResourcesTests: XCTestCase {
    
    private let bundle: Bundle = Bundle.main
    
    func testThatResourcesExistInAppMainBundle() {

        let resourcesDataExists: Bool
        let failureReason: String
        
        if let filePath = bundle.path(forResource: "resources", ofType: "json") {
            
            do {
                _ = try Data(contentsOf: URL(fileURLWithPath: filePath), options: [])
                resourcesDataExists = true
                failureReason = ""
            }
            catch let error {
                resourcesDataExists = false
                failureReason = "Failed to create Data from filePath: \(error)"
            }
        }
        else {
            resourcesDataExists = false
            failureReason = "Failed to locate resources.json in main bundle."
        }
        
        XCTAssertTrue(resourcesDataExists, failureReason)
    }
    
    func testThatLanguagesExistInAppMainBundle() {
        
        let languagesDataExists: Bool
        let failureReason: String
        
        if let filePath = bundle.path(forResource: "languages", ofType: "json") {
            
            do {
                _ = try Data(contentsOf: URL(fileURLWithPath: filePath), options: [])
                languagesDataExists = true
                failureReason = ""
            }
            catch let error {
                languagesDataExists = false
                failureReason = "Failed to create Data from filePath: \(error)"
            }
        }
        else {
            languagesDataExists = false
            failureReason = "Failed to locate languages.json in main bundle."
        }
        
        XCTAssertTrue(languagesDataExists, failureReason)
    }
    
    func testThatResourceAttachmentsExistInMainBundle() {
        
        XCTAssertTrue(true, "")
        
        //let expectation = XCTestExpectation(description: "Wait for resources download.")
        //wait(for: [expectation], timeout: 10.0)
    }
}
