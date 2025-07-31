//
//  RepositorySyncTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine
import RealmSwift

struct RepositorySyncTests {
    
    struct TestArgument {
        let cachePolicy: RepositorySyncCachePolicy
    }
    
    @Test("""
        Test that sink is triggered when fetching an object where the object doesn't exist in the database and the object is not stored in the database when fetched externally.
        """,
          arguments: [
            TestArgument(cachePolicy: .fetchIgnoringCacheData),
            TestArgument(cachePolicy: .returnCacheDataDontFetch),
            TestArgument(cachePolicy: .returnCacheDataElseFetch),
            TestArgument(cachePolicy: .returnCacheDataAndFetch)
          ]
    )
    @MainActor func testThatSinkIsTriggeredOnceWhenTheDatabaseIsEmptyAndNoExternalObjectIsStored(argument: TestArgument) async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let realmDatabase: RealmDatabase = Self.getRealmDatabase(addObjects: [])
        
        let repositorySync = RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject>(
            externalDataFetch: Self.getEmptyExternalDataFetch(),
            realmDatabase: realmDatabase,
            dataModelMapping: MockRepositorySyncMapping()
        )
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let sleepingTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                repositorySync
                    .getObjectPublisher(id: "1", cachePolicy: argument.cachePolicy, requestPriority: .medium)
                    .sink { response in
                        
                        sinkCount += 1
                        
                        confirmation()
                        sleepingTask.cancel()
                        continuation.resume(returning: ())
                    }
                    .store(in: &cancellables)
            }
        }
        
        #expect(sinkCount == 1)
    }
    
    @Test("""
        Test that sink is triggered twice, once for the initial call and once when the external object is stored in the database.
        """,
          arguments: [
            TestArgument(cachePolicy: .fetchIgnoringCacheData),
            TestArgument(cachePolicy: .returnCacheDataElseFetch),
            TestArgument(cachePolicy: .returnCacheDataAndFetch)
          ]
    )
    @MainActor func testThatSinkIsTriggeredTwiceWhenTheDatabaseIsEmptyAndAnExternalObjectIsStored(argument: TestArgument) async {
        
        // TODO: I need to inject the realm database file name so it's unique per argument being tested and then delete the realm file when the test completes. ~Levi
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let realmDatabase: RealmDatabase = Self.getRealmDatabase(addObjects: [])
        
        let externalDataFetch = MockRepositorySyncExternalDataFetch(
            objects: [
                MockRepositorySyncDataModel(id: "1", name: "Data Model 1")
            ]
        )
        
        let repositorySync = RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject>(
            externalDataFetch: externalDataFetch,
            realmDatabase: realmDatabase,
            dataModelMapping: MockRepositorySyncMapping()
        )
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 2) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let sleepingTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                repositorySync
                    .getObjectPublisher(id: "1", cachePolicy: argument.cachePolicy, requestPriority: .medium)
                    .sink { response in
                        
                        sinkCount += 1
                        
                        confirmation()
                        
                        if sinkCount == 2 {
                            sleepingTask.cancel()
                            continuation.resume(returning: ())
                        }
                    }
                    .store(in: &cancellables)
            }
        }
        
        #expect(sinkCount == 2)
    }
}

extension RepositorySyncTests {
    
    private static func getRealmDatabase(addObjects: [Object]) -> RealmDatabase {
        
        let realmDatabase: RealmDatabase = RealmDatabase(
            databaseConfiguration: RealmDatabaseConfiguration(
                cacheType: .disk(
                    fileName: "RepositorySyncTests",
                    migrationBlock: {migration,oldSchemaVersion in }),
                schemaVersion: 1
            )
        )
        
        _ = realmDatabase.deleteAllObjects()
        
        if addObjects.count > 0 {
            
            _ = realmDatabase.writeObjects(realm: realmDatabase.openRealm()) { realm in
                return addObjects
            }
        }

        return realmDatabase
    }
    
    private static func getEmptyExternalDataFetch() -> MockRepositorySyncExternalDataFetch {
        return MockRepositorySyncExternalDataFetch(objects: [])
    }
}
