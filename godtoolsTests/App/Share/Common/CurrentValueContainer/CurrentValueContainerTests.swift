//
//  CurrentValueContainerTests.swift
//  godtools
//
//  Created by Levi Eggert on 3/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import XCTest
@testable import godtools
import Combine

class CurrentValueContainerTests: XCTestCase {
    
    enum MyBool: String {
        case firstValue = "0"
        
        var id: String {
            return rawValue
        }
    }
    
    private var myBoolValueContainer: CurrentValueContainer<Bool, Never> = CurrentValueContainer()
    private var cancellables: Set<AnyCancellable> = Set()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        myBoolValueContainer.removeAll()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCurrentValueIsNilOnFirstAccess() {
        
        XCTAssertNil(myBoolValueContainer.getValue(id: MyBool.firstValue.id), "Value should be nil on first access.")
    }
    
    func testCurrentValueIsNilAfterRemoval() {
        
        let id: String = MyBool.firstValue.id
        
        myBoolValueContainer.sendValue(id: id, value: true)
        
        XCTAssertTrue(myBoolValueContainer.getValue(id: id) == true, "Value should be true.")
        
        myBoolValueContainer.remove(id: id)
        
        XCTAssertNil(myBoolValueContainer.getValue(id: id), "Value should be nil.")
    }
    
    func testCurrentValueIsTrueWhenSendingAValueOfTrue() {
        
        myBoolValueContainer.sendValue(id: MyBool.firstValue.id, value: true)
        
        XCTAssertTrue(myBoolValueContainer.getValue(id: MyBool.firstValue.id) == true, "Value should be true.")
    }
    
    func testCurrentValueIsFalseOnSubsequentFetches() {
        
        let id: String = MyBool.firstValue.id
        
        myBoolValueContainer.sendValue(id: id, value: false)
        
        let publisherExpectation = expectation(description: "")
        
        var publisherValueRef: Bool?
        
        myBoolValueContainer
            .getPublisher(id: id)
            .sink { _ in
                
            } receiveValue: { (value: Bool?) in
                
                publisherValueRef = value
                
                publisherExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [publisherExpectation], timeout: 1)
        
        XCTAssertTrue(myBoolValueContainer.getValue(id: MyBool.firstValue.id) == false, "Value should be false.")
        XCTAssertTrue(myBoolValueContainer.getCurrentValueSubject(id: MyBool.firstValue.id).value == false, "Value should be false.")
        XCTAssertTrue(publisherValueRef == false, "Value should be false on publisher sink.")
    }
}
