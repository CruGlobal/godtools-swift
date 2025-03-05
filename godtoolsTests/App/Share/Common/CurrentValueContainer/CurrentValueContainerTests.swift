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
        case secondValue = "1"
        
        var id: String {
            return rawValue
        }
    }
    
    private var myBoolValueContainer: CurrentValueContainer<Bool, Error> = CurrentValueContainer()
    private var cancellables: Set<AnyCancellable> = Set()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        myBoolValueContainer.unregisterAllObjects()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testRegisteringObjectExists() {
        
        let id: String = MyBool.firstValue.id
        
        XCTAssertNil(myBoolValueContainer.object(id: id), "Should be nil since object isn't registered.")
        
        _ = myBoolValueContainer.registerObject(id: id)
        
        XCTAssertNotNil(myBoolValueContainer.object(id: id), "Should not be nil since object is now registered.")
    }
    
    func testUnregisteringObjectIsRemoved() {
        
        let id: String = MyBool.firstValue.id
        
        _ = myBoolValueContainer.registerObject(id: id)
        
        XCTAssertNotNil(myBoolValueContainer.object(id: id), "Should not be nil since object is now registered.")
        
        myBoolValueContainer.unregisterObject(id: id)
        
        XCTAssertNil(myBoolValueContainer.object(id: id), "Should be nil since object was unregistered.")
    }
    
    func testUnregisteringAllObjectsThatAllObjectsAreRemoved() {
        
        _ = myBoolValueContainer.registerObject(id: MyBool.firstValue.id)
        _ = myBoolValueContainer.registerObject(id: MyBool.secondValue.id)
        
        XCTAssertNotNil(myBoolValueContainer.object(id: MyBool.firstValue.id), "Should not be nil since object is now registered.")
        XCTAssertNotNil(myBoolValueContainer.object(id: MyBool.secondValue.id), "Should not be nil since object is now registered.")
        
        myBoolValueContainer.unregisterAllObjects()
        
        XCTAssertNil(myBoolValueContainer.object(id: MyBool.firstValue.id), "Should be nil since all objects were unregistered.")
        XCTAssertNil(myBoolValueContainer.object(id: MyBool.secondValue.id), "Should be nil since all objects were unregistered.")
    }
    
    func testThatInitialValueIsNilWhenFirstRegisteringAnObject() {
        
        let object: CurrentValueObject<Bool, Error> = myBoolValueContainer.registerObject(id: MyBool.firstValue.id)
        
        XCTAssertNil(object.value, "Value should be nil since object was just registered.")
    }
    
    func testThatValueOfObjectIsSet() {
        
        let object: CurrentValueObject<Bool, Error> = myBoolValueContainer.registerObject(id: MyBool.firstValue.id)
        
        object.setValue(value: true)
        
        XCTAssertTrue(object.value == true, "Value should be true.")
    }
    
    func testThatValueOfObjectIsRemoved() {
        
        let object: CurrentValueObject<Bool, Error> = myBoolValueContainer.registerObject(id: MyBool.firstValue.id)
        
        object.setValue(value: false)
        
        XCTAssertTrue(object.value == false, "Value should be false.")
        
        object.removeValue()
        
        XCTAssertTrue(object.value == nil, "Value should be nil.")
    }
    
    func testSendingAValueIsReceivedByThePublisher() {
        
        let id: String = MyBool.firstValue.id
        
        let object: CurrentValueObject<Bool, Error> = myBoolValueContainer.registerObject(id: id)
        
        XCTAssertTrue(object.value == nil, "Value should be nil.")
        
        object.setValue(value: false)
        
        XCTAssertTrue(object.value == false, "Value should be false.")

        let publisherExpectation = expectation(description: "")
        
        var publisherValueRef_1: Bool?
        var publisherValueRef_2: Bool?
        var receiveCount: Int = 0
        
        object
            .publisher.dropFirst()
            .sink(receiveCompletion: { completion in
                
                
            }, receiveValue: { (value: Bool?) in
                
                receiveCount += 1
                
                if receiveCount == 1 {
                    publisherValueRef_1 = value
                }
                else if receiveCount == 2 {
                    publisherValueRef_2 = value
                    publisherExpectation.fulfill()
                }
            })
            .store(in: &cancellables)

        object.sendValue(value: true)
        object.sendValue(value: false)
        
        wait(for: [publisherExpectation], timeout: 1)
        
        XCTAssertTrue(publisherValueRef_1 == true, "Value should be true on publisher sink.")
        XCTAssertTrue(publisherValueRef_2 == false, "Value should be false on publisher sink.")
    }
    
    func testSendingCompletionFinishedIsReceivedByThePublisher() {
        
        let id: String = MyBool.firstValue.id
        
        let object: CurrentValueObject<Bool, Error> = myBoolValueContainer.registerObject(id: id)
        
        XCTAssertTrue(object.value == nil, "Value should be nil.")
        
        object.setValue(value: false)
        
        XCTAssertTrue(object.value == false, "Value should be false.")

        let publisherExpectation = expectation(description: "")
        
        var completionRef: Subscribers.Completion<Error>?
        
        object
            .publisher
            .sink(receiveCompletion: { completion in
                
                completionRef = completion
                
                publisherExpectation.fulfill()
                
            }, receiveValue: { (value: Bool?) in
                
            })
            .store(in: &cancellables)
        
        object.sendCompletion(completion: .finished)
        
        wait(for: [publisherExpectation], timeout: 1)
        
        let isFinished: Bool
        
        switch completionRef {
        case .finished:
            isFinished = true
        case .failure( _):
            isFinished = false
        case .none:
            isFinished = false
        }
        
        XCTAssertTrue(isFinished == true, "Completion to be finished.")
    }
    
    func testSendingCompletionErrorIsReceivedByThePublisher() {
        
        let id: String = MyBool.firstValue.id
        
        let object: CurrentValueObject<Bool, Error> = myBoolValueContainer.registerObject(id: id)
        
        XCTAssertTrue(object.value == nil, "Value should be nil.")
        
        object.setValue(value: false)
        
        XCTAssertTrue(object.value == false, "Value should be false.")

        let publisherExpectation = expectation(description: "")
        
        var completionRef: Subscribers.Completion<Error>?
        
        object
            .publisher
            .sink(receiveCompletion: { completion in
                
                completionRef = completion
                
                publisherExpectation.fulfill()
                
            }, receiveValue: { (value: Bool?) in
                
            })
            .store(in: &cancellables)
        
        let objectError: Error = NSError.errorWithDescription(description: "Test sending error to object.")
        
        object.sendCompletion(completion: .failure(objectError))
        
        wait(for: [publisherExpectation], timeout: 1)
        
        let errorRef: Error?
        
        switch completionRef {
        case .finished:
            errorRef = nil
        case .failure(let value):
            errorRef = value
        case .none:
            errorRef = nil
        }
        
        XCTAssertNotNil(errorRef, "Error should not be nil.")
    }
}
