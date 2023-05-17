//
//  RealmDatabaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 5/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import XCTest
@testable import godtools
import RealmSwift
import Combine

class RealmDatabaseTests: XCTestCase {
    
    private let realmDatabase: RealmDatabase = RealmDatabase(
        databaseConfiguration: RealmDatabaseConfiguration(
            cacheType: .inMemory(identifier: "tests-inMemory-realm-database"),
            schemaVersion: 1
        )
    )
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        _ = realmDatabase.deleteAllObjects()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    private func addTestObjectsWithIds(ids: [String]) -> Error? {
        
        let realm: Realm = realmDatabase.openRealm()
        
        var realmObjects: [Object] = Array()
        
        for testObjectId in ids {
            
            let existingRealmObject: TestRealmObject? = realmDatabase.readObject(realm: realm, primaryKey: testObjectId)
            
            let testRealmObject: TestRealmObject = existingRealmObject ?? TestRealmObject()
            
            testRealmObject.id = testObjectId
            testRealmObject.name = "name - " + testObjectId
            
            realmObjects.append(testRealmObject)
        }
        
        return realmDatabase.updateObjects(realm: realm, shouldAddObjectsToRealm: true, writeClosure: { (realm: Realm) in
            return realmObjects
        })
    }
    
    func testReadObjectsExist() {
        
        let testObjectIds: [String] = ["x-1", "x-2", "x-3"]
        
        _ = addTestObjectsWithIds(ids: testObjectIds)
        
        for primaryKey in testObjectIds {
            
            let object: TestRealmObject? = realmDatabase.readObject(primaryKey: primaryKey)
            
            XCTAssertNotNil(object)
        }
        
        let nonExistingObjectIds: [String] = ["x-4", "x-5", "x-6"]
        
        for primaryKey in nonExistingObjectIds {
            
            let object: TestRealmObject? = realmDatabase.readObject(primaryKey: primaryKey)
            
            XCTAssertNil(object)
        }
    }
    
    func testReadObjectsWithRealmInstanceExist() {
        
        let testObjectIds: [String] = ["x-1", "x-2", "x-3"]
        
        _ = addTestObjectsWithIds(ids: testObjectIds)
        
        let realm: Realm = realmDatabase.openRealm()
        
        for primaryKey in testObjectIds {
            
            let object: TestRealmObject? = realmDatabase.readObject(realm: realm, primaryKey: primaryKey)
            
            XCTAssertNotNil(object)
        }
        
        let nonExistingObjectIds: [String] = ["x-4", "x-5", "x-6"]
        
        for primaryKey in nonExistingObjectIds {
            
            let object: TestRealmObject? = realmDatabase.readObject(realm: realm, primaryKey: primaryKey)
            
            XCTAssertNil(object)
        }
    }
    
    func testDeleteObjects() {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let testObjectIds: [String] = ["a", "b", "c", "d", "e", "f"]
        
        _ = addTestObjectsWithIds(ids: testObjectIds)
        
        var objectsToDelete: [Object] = Array()
        
        // Test objects exist
        for primaryKey in testObjectIds {
            
            let object: TestRealmObject? = realmDatabase.readObject(realm: realm, primaryKey: primaryKey)
            
            XCTAssertNotNil(object)
            
            if let object = object {
                objectsToDelete.append(object)
            }
        }
        
        // Test objects have been deleted
        _ = realmDatabase.deleteObjects(realm: realm, objects: objectsToDelete)
        
        for primaryKey in testObjectIds {
            
            let object: TestRealmObject? = realmDatabase.readObject(realm: realm, primaryKey: primaryKey)
            
            XCTAssertNil(object)
        }
    }
    
    func testReadUpdateDeleteObjects() {
        
        let testObjectIds: [String] = ["a", "b", "c", "d", "e", "f"]
                                
        let expectation = expectation(description: "")
             
        var finishedError: Error?
        
        realmDatabase.updateObjectsPublisher(shouldAddObjectsToRealm: true, writeClosure: { (realm: Realm) in
            
            // Add test objects
            
            var realmObjectsToAdd: [Object] = Array()
            
            for testObjectId in testObjectIds {
                
                let existingRealmObject: TestRealmObject? = self.realmDatabase.readObject(realm: realm, primaryKey: testObjectId)
                
                let testRealmObject: TestRealmObject = existingRealmObject ?? TestRealmObject()
                
                testRealmObject.id = testObjectId
                testRealmObject.name = "name - " + testObjectId
                
                realmObjectsToAdd.append(testRealmObject)
            }
            
            return realmObjectsToAdd
        })
        .flatMap({ (void: Void) -> AnyPublisher<Void, Never> in
            
            // Test objects have been added
            
            let realm: Realm = self.realmDatabase.openRealm()
            
            for primaryKey in testObjectIds {
                
                let object: TestRealmObject? = self.realmDatabase.readObject(realm: realm, primaryKey: primaryKey)
                
                XCTAssertNotNil(object)
            }
            
            return Just(())
                .eraseToAnyPublisher()
        })
        .flatMap({ (void: Void) -> AnyPublisher<Void, Error> in
            
            let realm: Realm = self.realmDatabase.openRealm()
            
            var realmObjectsToDelete: [Object] = Array()
            
            for primaryKey in testObjectIds {
                
                let object: TestRealmObject? = self.realmDatabase.readObject(realm: realm, primaryKey: primaryKey)
                
                if let object = object {
                    realmObjectsToDelete.append(object)
                }
            }
            
            return self.realmDatabase.deleteObjectsPublisher(objects: realmObjectsToDelete)
                .eraseToAnyPublisher()
        })
        .flatMap({ (void: Void) -> AnyPublisher<Void, Never> in
            
            // Test objects have been deleted
            
            let realm: Realm = self.realmDatabase.openRealm()
            
            for primaryKey in testObjectIds {
                
                let object: TestRealmObject? = self.realmDatabase.readObject(realm: realm, primaryKey: primaryKey)
                
                XCTAssertNil(object)
            }
            
            return Just(())
                .eraseToAnyPublisher()
        })
        .receiveOnMain()
        .sink { subscribersCompletion in
                        
            switch subscribersCompletion {
                
            case .finished:
                finishedError = nil
                
            case .failure(let error):
                finishedError = error
            }
            
            DispatchQueue.main.async {
                expectation.fulfill()
            }
            
        } receiveValue: { _ in
            
        }
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 10)
        
        XCTAssertNil(finishedError, finishedError?.localizedDescription ?? "")
    }
}


