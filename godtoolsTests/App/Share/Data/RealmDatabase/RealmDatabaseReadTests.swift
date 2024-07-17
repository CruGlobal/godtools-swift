//
//  RealmDatabaseReadTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 5/3/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import XCTest
@testable import godtools
import RealmSwift
import Combine

class RealmDatabaseReadTests: XCTestCase {
    
    private let realmDatabase: RealmDatabase = RealmDatabase(
        databaseConfiguration: RealmDatabaseConfiguration(
            cacheType: .disk(
                fileName: "RealmDatabaseReadTests",
                migrationBlock: {migration,oldSchemaVersion in }),
            schemaVersion: 1
        )
    )
    
    private let testObjectIds: [String] = ["0", "1", "2", "3", "4"]
    
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
    
    func testReadObjectDoesntCrashDueToRealmAccessedFromIncorrectThread() {
        
        let numberOfIterations: Int = 5
        
        let requests = (0 ..< numberOfIterations).map({ _ in
            readAndMapObjectEachObjectFromOnChangePublisher(objectIds: testObjectIds)
        })
        
        let expectation = expectation(description: "")
        
        var mappedObjectsRef: [TestRealmObjectMapping] = Array()
        
        Publishers.MergeMany(requests)
            .collect()
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { (mappedObjects: [[TestRealmObjectMapping?]]) in
                
                mappedObjectsRef = mappedObjects
                    .flatMap { $0 }
                    .compactMap { $0 }
                
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(mappedObjectsRef.count == (testObjectIds.count * numberOfIterations))
    }
    
    private func readAndMapObjectEachObjectFromOnChangePublisher(objectIds: [String]) -> AnyPublisher<[TestRealmObjectMapping?], Never> {
        
        return onChangePublisher()
            .flatMap({ (onChange: Void) -> AnyPublisher<[TestRealmObjectMapping?], Never> in
                
                let requests = objectIds.map {
                    self.readAndMapRealmObjectPublisher(id: $0)
                }
                
                return Publishers.MergeMany(requests)
                    .collect()
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func onChangePublisher() -> AnyPublisher<Void, Never> {
        return Just(())
            .eraseToAnyPublisher()
    }
    
    private func readAndMapRealmObjectPublisher(id: String) -> AnyPublisher<TestRealmObjectMapping?, Never> {
        
        return realmDatabase.readObjectPublisher(primaryKey: id) { (object: TestRealmObject?) in
            
            guard let realmObject = object else {
                return nil
            }
            
            return TestRealmObjectMapping(realmObject: realmObject)
        }
    }
    
    func testReadObjectsDoesntCrashDueToRealmAccessedFromIncorrectThread() {
        
        let numberOfIterations: Int = 5
        
        let requests = (0 ..< numberOfIterations).map({ _ in
            readAndMapAllObjectsFromOnChangePublisher()
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
    
    private func readAndMapAllObjectsFromOnChangePublisher() -> AnyPublisher<[TestRealmObjectMapping], Never> {
        
        return onChangePublisher()
            .flatMap({ (onChange: Void) -> AnyPublisher<[TestRealmObjectMapping], Never> in
                
                return self.readAndMapAllRealmObjectsPublisher()
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func readAndMapAllRealmObjectsPublisher() -> AnyPublisher<[TestRealmObjectMapping], Never> {
        
        return realmDatabase.readObjectsPublisher(mapInBackgroundClosure: { (results: Results<TestRealmObject>) in
            
            return results.map({
                TestRealmObjectMapping(realmObject: $0)
            })
        })
        .eraseToAnyPublisher()
    }
}
