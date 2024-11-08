//
//  RealmDatabaseObserveChangesTests.swift
//  godtools
//
//  Created by Levi Eggert on 11/8/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import XCTest
@testable import godtools
import RealmSwift
import Combine

class RealmDatabaseObserveChangesTests: XCTestCase {
    
    private let realmDatabase: RealmDatabase = RealmDatabase(
        databaseConfiguration: RealmDatabaseConfiguration(
            cacheType: .disk(
                fileName: "RealmDatabaseObserveChangesTests",
                migrationBlock: {migration,oldSchemaVersion in }),
            schemaVersion: 1
        )
    )
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testObserveChangesFires() {
        
        let expectation = expectation(description: "")
        
        var didReceiveValue: Bool = false
        
        realmDatabase
            .observeCollectionChangesPublisher(objectClass: TestRealmObject.self, prepend: false)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { _ in
                
                if !didReceiveValue {
                    
                    didReceiveValue = true
                    
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)

        XCTAssertTrue(didReceiveValue)
    }
}
