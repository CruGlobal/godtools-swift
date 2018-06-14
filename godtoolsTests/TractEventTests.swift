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
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOneEventOneAttribute() {
        guard let analyticsElement = fetchAnalyticsElementFromFile(filename: "analytics-test1", filetype: "xml") else { XCTFail(); return }
        
        let dict = TractEventHelper.buildAnalyticsEvents(data: XMLIndexer(analyticsElement))
        
        XCTAssertEqual("adobe", dict["system"])
        XCTAssertEqual("foo", dict["action"])
        XCTAssertEqual("visible", dict["trigger"])
        XCTAssertEqual("5", dict["delay"])
        XCTAssertEqual("baz", dict["bar"])
    }
    
    func testTwoEventswWithSameAttribute() {
        guard let analyticsElement = fetchAnalyticsElementFromFile(filename: "analytics-test2", filetype: "xml") else { XCTFail(); return }
        
        let dict = TractEventHelper.buildAnalyticsEvents(data: XMLIndexer(analyticsElement))
        
        //TODO: problem here is that if there are multiple events triggered together they aren't differentiated in the dictionary
        
        XCTAssertEqual("adobe", dict["system"])
        XCTAssertEqual("foo", dict["action"])
        XCTAssertEqual("visible", dict["trigger"])
        XCTAssertEqual("5", dict["delay"])
        XCTAssertEqual("baz", dict["bar"])
    }
    
    private func fetchAnalyticsElementFromFile(filename: String, filetype: String) -> XMLElement? {
        guard let testXMLPath = Bundle(for: self.classForCoder).path(forResource: filename, ofType: filetype) else { XCTFail(); return nil}
        
        do {
            let testXML = try String(contentsOfFile: testXMLPath, encoding: String.Encoding.utf8)
            
            // unwrap the analytics element the "root element".
            guard let rootElement = SWXMLHash.parse(testXML).element else { XCTFail(); return nil}
            guard let analyticsElement = rootElement.children.first as? XMLElement else { XCTFail(); return nil }
            return analyticsElement
        } catch {
            XCTFail(error.localizedDescription)
            return nil
        }
    }
}
