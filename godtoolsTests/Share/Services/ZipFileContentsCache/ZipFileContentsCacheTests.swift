//
//  ZipFileContentsCacheTests.swift
//  GodTools-RendererTests
//
//  Created by Levi Eggert on 4/19/20.
//  Copyright © 2020 Levi Eggert. All rights reserved.
//

import XCTest
@testable import godtools

class ZipFileContentsCacheTests: XCTestCase {
    
    private let testZipFileContents: [String] = ["file_1.rtf", "file_2.rtf", "file_3.rtf", "file_4.rtf"]
    private let testZipFileName: String = "test_for_zip_file_contents_cache"
    
    private var cache: ZipFileContentsCache!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cache = ZipFileContentsCache()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        cache = nil
    }
    
    private func newTestZipFileData() -> Data? {
        
        if let path = Bundle.main.path(forResource: testZipFileName, ofType: "zip") {
            
            let url: URL = URL(fileURLWithPath: path)
            
            do {
                let data: Data? = try Data(contentsOf: url)
                return data
            }
            catch let error {
                print("Error creating new test zip file data: \(error)")
                return nil
            }
        }
        
        return nil
    }
    
    func testThatAllContentsAreCachedFromTestZipFile() {
        
        var cacheContentsPaths: [String] = Array()
        var testError: Error?
        
        let zipData: Data = newTestZipFileData()!
        
        let location = ZipFileContentsCacheLocation(relativeUrl: URL(string: "test_zip_contents_1"))
                
        switch cache.cacheContents(location: location, zipData: zipData) {
            
            case .success( _):
                
                switch cache.getContentsPaths(location: location) {
                
                case .success(let contentsPaths):
                    cacheContentsPaths = contentsPaths
                
                case .failure(let error):
                    testError = error
                }
                
            case .failure(let error):
                testError = error
        }
        
        for testContentPath in testZipFileContents {
            XCTAssertTrue(cacheContentsPaths.contains(testContentPath), "Failed because a file path from \(testZipFileName).zip does not exist in the cached directory. File path: \(testContentPath) was not cached.")
        }
                
        XCTAssertNil(testError, "Failed due to error: \(String(describing: testError))")
    }
}
