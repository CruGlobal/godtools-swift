//
//  TractEventTests.swift
//  godtoolsTests
//
//  Created by Ryan Carlson on 6/14/18.
//  Copyright © 2018 Cru. All rights reserved.
//

import XCTest
import SWXMLHash

class TractEventTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        guard let testXMLPath = Bundle(for: self.classForCoder).path(forResource: "analytics-test", ofType: "xml") else { XCTFail(); return }
        
        do {
            let testXML = try String(contentsOfFile: testXMLPath, encoding: String.Encoding.utf8)
            
            let parsedXML = SWXMLHash.parse(testXML)
            
            let dict = TractEventHelper.buildAnalyticsEvents(data: parsedXML)
            
            debugPrint(dict)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
