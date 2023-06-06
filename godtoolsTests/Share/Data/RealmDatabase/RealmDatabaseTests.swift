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
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    private func getInMemoryRealmDatabase() -> RealmDatabase {
        return RealmDatabase(
            databaseConfiguration: RealmDatabaseConfiguration(
                cacheType: .inMemory(identifier: UUID().uuidString),
                schemaVersion: 1
            )
        )
    }
    
    private func getRandomTestObjectIds(count: Int) -> [String] {
        
        var ids: [String] = Array()
        
        for _ in 0 ..< count {
            ids.append(UUID().uuidString)
        }
        
        return ids
    }

    private func addTestObjectsWithIds(realmDatabase: RealmDatabase, ids: [String]) -> Error? {
        
        let realm: Realm = realmDatabase.openRealm()
        
        var realmObjects: [Object] = Array()
        
        for testObjectId in ids {
                        
            let testRealmObject: TestRealmObject = TestRealmObject()
            
            testRealmObject.id = testObjectId
            testRealmObject.name = "name - " + testObjectId
            
            realmObjects.append(testRealmObject)
        }
        
        return realmDatabase.writeObjects(realm: realm, writeClosure: { (realm: Realm) in
            return realmObjects
        })
    }
    
    func testReadObjectsExist() {
        
        let realmDatabase: RealmDatabase = getInMemoryRealmDatabase()
        
        let testObjectIds: [String] = getRandomTestObjectIds(count: 3)
        
        _ = addTestObjectsWithIds(realmDatabase: realmDatabase, ids: testObjectIds)
        
        for primaryKey in testObjectIds {
            
            let object: TestRealmObject? = realmDatabase.readObject(primaryKey: primaryKey)
            
            XCTAssertNotNil(object)
        }
        
        let nonExistingObjectIds: [String] = getRandomTestObjectIds(count: 3)
        
        for primaryKey in nonExistingObjectIds {
            
            let object: TestRealmObject? = realmDatabase.readObject(primaryKey: primaryKey)
            
            XCTAssertNil(object)
        }
    }
    
    func testDeleteObjects() {
        
        let realmDatabase: RealmDatabase = getInMemoryRealmDatabase()
        
        let realm: Realm = realmDatabase.openRealm()
        
        let testObjectIds: [String] = getRandomTestObjectIds(count: 6)
        
        _ = addTestObjectsWithIds(realmDatabase: realmDatabase, ids: testObjectIds)
        
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
    
    func testWriteExistingObject() {
        
        let realmDatabase: RealmDatabase = getInMemoryRealmDatabase()
        
        let duplicateObjectId: String = "duplicate-object-id"
        let testObjectIds: [String] = [duplicateObjectId, duplicateObjectId, duplicateObjectId, duplicateObjectId]
        
        let realm: Realm = realmDatabase.openRealm()
        
        var index: Int = 0
        var lastObjectName: String = "-"
        
        for id in testObjectIds {
            
            let objectName: String = "name \(index)"
            
            if index == testObjectIds.count - 1 {
                lastObjectName = objectName
            }
            
            _ = realmDatabase.writeObjects(realm: realm) { (realm: Realm) in
                
                let object: TestRealmObject = TestRealmObject()
                object.id = id
                object.name = objectName
                
                return [object]
            }
            
            index += 1
        }
        
        let object: TestRealmObject? = realmDatabase.readObject(primaryKey: duplicateObjectId)

        XCTAssertEqual(lastObjectName, object?.name)
    }
}


