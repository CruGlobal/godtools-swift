//
//  RealmDatabaseWriteTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 5/3/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import XCTest
@testable import godtools
import RealmSwift
import Combine

class RealmDatabaseWriteTests: XCTestCase {
    
    private let realmDatabase: RealmDatabase = RealmDatabase(
        databaseConfiguration: RealmDatabaseConfiguration(
            cacheType: .disk(
                fileName: "RealmDatabaseWriteTests",
                migrationBlock: {migration,oldSchemaVersion in }),
            schemaVersion: 1
        )
    )
    
    private let testObjectIds: [String] = ["90", "91", "92", "93", "94"]
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let realm: Realm = realmDatabase.openRealm()
        let databaseIsEmpty: Bool = realm.objects(TestRealmObject.self).isEmpty
        
        if databaseIsEmpty {
                        
            var realmObjects: [Object] = Array()
            
            for testObjectId in testObjectIds {
                            
                let testRealmObject: TestRealmObject = TestRealmObject()
                
                testRealmObject.id = testObjectId
                testRealmObject.name = "name - " + testObjectId
                
                realmObjects.append(testRealmObject)
            }
            
            do {
                try realm.write {
                    realm.add(realmObjects, update: .all)
                }
            }
            catch let error {
                print("error: \(error)")
            }
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testWriteObjectsDoesntCrashDueToRealmAccessedFromIncorrectThread() {
        
        let numberOfIterations: Int = 5
        
        let requests = (0 ..< numberOfIterations).map({ _ in
            writeAndMapObjectsFromOnChangePublisher(objectIds: testObjectIds)
        })
        
        let expectation = expectation(description: "")
        
        var mappedObjectsRef: [TestRealmObjectMapping] = Array()
        
        Publishers.MergeMany(requests)
            .collect()
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { (mappedObjects: [[TestRealmObjectMapping]]) in
                
                mappedObjectsRef = mappedObjects
                    .flatMap { $0 }
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(mappedObjectsRef.count == (testObjectIds.count * numberOfIterations))
    }
    
    private func onChangePublisher() -> AnyPublisher<Void, Never> {
        return Just(())
            .eraseToAnyPublisher()
    }
    
    private func writeAndMapObjectsFromOnChangePublisher(objectIds: [String]) -> AnyPublisher<[TestRealmObjectMapping], Never> {
        
        return onChangePublisher()
            .flatMap({ (onChange: Void) -> AnyPublisher<[TestRealmObjectMapping], Never> in
                
                return self.writeAndMapRealmObjectsPublisher(objectIds: objectIds)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func writeAndMapRealmObjectsPublisher(objectIds: [String]) -> AnyPublisher<[TestRealmObjectMapping], Never> {
        
        return realmDatabase.writeObjectsPublisher(writeClosure: { (realm: Realm) -> [TestRealmObject] in
            
            var realmObjects: [TestRealmObject] = Array()
            
            for objectId in objectIds {
                            
                let testRealmObject: TestRealmObject
                let existingObject: TestRealmObject? = self.realmDatabase.readObject(realm: realm, primaryKey: objectId)
                
                if let existingObject = existingObject {
                    testRealmObject = existingObject
                }
                else {
                    testRealmObject = TestRealmObject()
                    testRealmObject.id = objectId
                }
                
                testRealmObject.name = "name - " + objectId
                
                realmObjects.append(testRealmObject)
            }
            
            return realmObjects
        }, mapInBackgroundClosure: { (objects: [TestRealmObject]) -> [TestRealmObjectMapping] in
            
            let mappedObjects: [TestRealmObjectMapping] = objects.map({
                TestRealmObjectMapping(realmObject: $0)
            })
            
            return mappedObjects
        })
        .catch({ (error: Error) in
            
            return Just([])
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}

