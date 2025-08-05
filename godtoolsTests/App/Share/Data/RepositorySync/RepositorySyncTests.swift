//
//  RepositorySyncTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import Combine
import RealmSwift

struct RepositorySyncTests {
    
    struct TestArgument {
        let realmFileName: String = "RepositorySyncTests_" + UUID().uuidString
        let cachePolicy: RepositorySyncCachePolicy
        let expectedConfirmationCount: Int
        let externalDataModels: [MockRepositorySyncDataModel]
        let expectedDataModelIds: [String]
    }
    
    // MARK: - Objects Tests
    
    @Test(arguments: [
            TestArgument(
                cachePolicy: .fetchIgnoringCacheData,
                expectedConfirmationCount: 1,
                externalDataModels: Self.getMockRepositorySyncDataModels(startingId: 1, count: 1),
                expectedDataModelIds: ["1"]
            ),
            TestArgument(
                cachePolicy: .fetchIgnoringCacheData,
                expectedConfirmationCount: 1,
                externalDataModels: Self.getMockRepositorySyncDataModels(startingId: 5, count: 4),
                expectedDataModelIds: ["5", "6", "7", "8"]
            ),
            TestArgument(
                cachePolicy: .fetchIgnoringCacheData,
                expectedConfirmationCount: 1,
                externalDataModels: Self.getMockRepositorySyncDataModels(startingId: 0, count: 2),
                expectedDataModelIds: ["0", "1"]
            )
          ]
    )
    @MainActor func fetchingExternalDataIsTriggeredOnceWhenIgnoringCachedData(argument: TestArgument) async {
        
        let repositorySync: RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject> = getRepositorySyncFromTestArgument(
            argument: argument
        )
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var sinkCount: Int = 0
        var responseRef: RepositorySyncResponse<MockRepositorySyncDataModel>?
        
        await confirmation(expectedCount: argument.expectedConfirmationCount) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                repositorySync
                    .getObjectsPublisher(
                        cachePolicy: argument.cachePolicy,
                        requestPriority: .medium
                    )
                    .sink { (response: RepositorySyncResponse<MockRepositorySyncDataModel>) in
                        
                        confirmation()
                        
                        sinkCount += 1
                        
                        if sinkCount == argument.expectedConfirmationCount {
                            
                            responseRef = response
                            
                            timeoutTask.cancel()
                            continuation.resume(returning: ())
                        }
                    }
                    .store(in: &cancellables)
            }
        }
        
        cleanUpRepositorySyncFromTestArgument(argument: argument)
        
        let responseDataModelIds: [String] = getSortedResponseObjectsDataModelIds(response: responseRef)
        
        #expect(responseDataModelIds == argument.expectedDataModelIds)
    }
    
    // MARK: - Object By Id Tests
    
    /*
    
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
        
        let externalDataFetch = Self.getExternalDataFetch(
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
    }*/
}

extension RepositorySyncTests {
    
    private func getRepositorySyncFromTestArgument(argument: TestArgument) -> RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject> {
     
        let realmDatabase: RealmDatabase = Self.getRealmDatabase(
            fileName: argument.realmFileName,
            addObjects: []
        )
        
        return RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject>(
            externalDataFetch: Self.getEmptyExternalDataFetch(),
            realmDatabase: realmDatabase,
            dataModelMapping: MockRepositorySyncMapping()
        )
    }
    
    private func cleanUpRepositorySyncFromTestArgument(argument: TestArgument) {
        
        _ = Self.deleteRealmDatabaseFile(fileName: argument.realmFileName)
    }
    
    private func getSortedResponseObjectsDataModelIds(response: RepositorySyncResponse<MockRepositorySyncDataModel>?) -> [String] {
        
        let responseObjects: [MockRepositorySyncDataModel] = response?.objects ?? Array()
        
        return responseObjects.map {
            $0.id
        }.sorted {
            $0 < $1
        }
    }
    
    private static func getRealmDatabaseConfiguration(fileName: String) -> RealmDatabaseConfiguration {
        return RealmDatabaseConfiguration(
            cacheType: .disk(
                fileName: fileName,
                migrationBlock: {migration,oldSchemaVersion in }),
            schemaVersion: 1
        )
    }
    
    private static func deleteRealmDatabaseFile(fileName: String) -> Error? {
        
        let databaseConfiguration: RealmDatabaseConfiguration = Self.getRealmDatabaseConfiguration(
            fileName: fileName
        )
        
        do {
            _ = try Realm.deleteFiles(for: databaseConfiguration.getRealmConfig())
            return nil
        }
        catch let error {
            return error
        }
    }
    
    private static func getRealmDatabase(fileName: String, addObjects: [Object]) -> RealmDatabase {
        
        let realmDatabase: RealmDatabase = RealmDatabase(
            databaseConfiguration: RealmDatabaseConfiguration(
                cacheType: .disk(
                    fileName: fileName,
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
        return Self.getExternalDataFetch(objects: [])
    }
    
    private static func getExternalDataFetch(objects: [MockRepositorySyncDataModel]) -> MockRepositorySyncExternalDataFetch {
        
        return MockRepositorySyncExternalDataFetch(
            objects: objects
        )
    }
    
    private static func getMockRepositorySyncDataModels(startingId: Int, count: Int) -> [MockRepositorySyncDataModel] {
        
        var dataModels: [MockRepositorySyncDataModel] = Array()
        
        for index in startingId ..< count {
            dataModels.append(
                MockRepositorySyncDataModel(
                    id: "\(index)",
                    name: "name \(index)"
                )
            )
        }
        
        return dataModels
    }
}
