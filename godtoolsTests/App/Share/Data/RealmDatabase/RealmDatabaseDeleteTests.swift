//
//  RealmDatabaseDeleteTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 5/3/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import XCTest
@testable import godtools
import RealmSwift
import Combine

class RealmDatabaseDeleteTests: XCTestCase {
    
    private let realmDatabase: RealmDatabase = RealmDatabase(
        databaseConfiguration: RealmDatabaseConfiguration(
            cacheType: .disk(
                fileName: "RealmDatabaseDeleteTests",
                migrationBlock: {migration,oldSchemaVersion in }),
            schemaVersion: 1
        )
    )
    
    private let testObjectIds: [String] = ["40", "41", "42", "43", "44"]
    
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
    
    private func onChangePublisher() -> AnyPublisher<Void, Never> {
        return Just(())
            .eraseToAnyPublisher()
    }
    
    func testDeleteAllObjects() {
        
        let error: Error? = realmDatabase.deleteAllObjects()
        
        XCTAssertNil(error, "Should not get any errors.")
        XCTAssertTrue(realmDatabase.openRealm().objects(TestRealmObject.self).isEmpty)
    }
    
    func testDeleteObjectsByPrimaryKeys() {
                
        let objectIdsToDelete: [String] = ["41", "43"]
        
        let expectation = expectation(description: "")
           
        var remainingObjectsRef: [TestRealmObjectMapping] = Array()
        
        onChangePublisher()
            .flatMap({ (onChange: Void) -> AnyPublisher<Void, Never> in
                
                return self.realmDatabase.deleteObjectsInBackgroundPublisher(
                    type: TestRealmObject.self,
                    primaryKeyPath: #keyPath(TestRealmObject.id),
                    primaryKeys: objectIdsToDelete
                )
                .catch({ (error: Error) in
                    return Just(Void())
                        .eraseToAnyPublisher()
                })
                .eraseToAnyPublisher()
            })
            .flatMap({ (objectsDeleted: Void) -> AnyPublisher<[TestRealmObjectMapping], Never> in
                
                return self.realmDatabase.readObjectsPublisher { (results: Results<TestRealmObject>) in
                    let mappedObjects: [TestRealmObjectMapping] = results.map({ TestRealmObjectMapping(realmObject: $0) })
                    return mappedObjects
                }
                .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink { (remainingObjects: [TestRealmObjectMapping]) in
                      
                remainingObjectsRef = remainingObjects
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        let remainingObjectIds: [String] = remainingObjectsRef.map({$0.id})
        
        XCTAssertTrue(remainingObjectIds.sorted() == ["40", "42", "44"])
    }
}
