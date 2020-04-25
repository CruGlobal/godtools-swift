//
//  FileCacheTests.swift
//  GodTools-RendererTests
//
//  Created by Levi Eggert on 4/19/20.
//  Copyright © 2020 Levi Eggert. All rights reserved.
//

import XCTest
@testable import godtools

class FileCacheTests: XCTestCase {
        
    private var cache: FileCache!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cache = ZipFileContentsCache()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        cache = nil
    }
}
