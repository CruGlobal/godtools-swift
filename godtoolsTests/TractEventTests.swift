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
        
        XCTAssertEqual("adobe", dict[0]["system"])
        XCTAssertEqual("foo", dict[0]["action"])
        XCTAssertEqual("visible", dict[0]["trigger"])
        XCTAssertEqual("5", dict[0]["delay"])
        XCTAssertEqual("baz", dict[0]["bar"])
    }
    
    func testTwoEventswWithSameAttribute() {
        guard let analyticsElement = fetchAnalyticsElementFromFile(filename: "analytics-test2", filetype: "xml") else { XCTFail(); return }
        
        let dict = TractEventHelper.buildAnalyticsEvents(data: XMLIndexer(analyticsElement))
        
        //TODO: problem here is that if there are multiple events triggered together they aren't differentiated in the dictionary
        
        XCTAssertEqual("adobe", dict[0]["system"])
        XCTAssertEqual("foo", dict[0]["action"])
        XCTAssertEqual("visible", dict[0]["trigger"])
        XCTAssertEqual("5", dict[0]["delay"])
        XCTAssertEqual("baz", dict[0]["bar"])
        
        XCTAssertEqual("adobe google", dict[1]["system"])
        XCTAssertEqual("foo2", dict[1]["action"])
        XCTAssertEqual("hidden", dict[1]["trigger"])
        XCTAssertEqual("45", dict[1]["delay"])
        XCTAssertEqual("quux", dict[1]["bar"])
        XCTAssertEqual("5", dict[1]["cru.emaillist"])
        
        
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
