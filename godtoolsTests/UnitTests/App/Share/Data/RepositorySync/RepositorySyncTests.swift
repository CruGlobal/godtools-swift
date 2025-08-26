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
        let initialPersistedObjectsIds: [String]
        let externalDataModelIds: [String]
        let expectedCacheResponseDataModelIds: [String]
        let expectedResponseDataModelIds: [String]
        let expectedNumberOfChanges: Int
        let cachePolicy: RepositorySyncCachePolicy
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: ["0", "1", "5", "6", "7", "8", "9"],
            expectedNumberOfChanges: 1,
            cachePolicy: .fetchIgnoringCacheData(requestPriority: .medium, observeChanges: false)
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["1", "2"],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: ["1", "2"],
            expectedNumberOfChanges: 1,
            cachePolicy: .fetchIgnoringCacheData(requestPriority: .medium, observeChanges: false)
        ),
        TestArgument(
            initialPersistedObjectsIds: ["2", "3"],
            externalDataModelIds: [],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: ["2", "3"],
            expectedNumberOfChanges: 1,
            cachePolicy: .fetchIgnoringCacheData(requestPriority: .medium, observeChanges: false)
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: [],
            expectedNumberOfChanges: 1,
            cachePolicy: .fetchIgnoringCacheData(requestPriority: .medium, observeChanges: false)
        ),
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: ["0", "1"],
            expectedNumberOfChanges: 1,
            cachePolicy: .returnCacheDataDontFetch(observeChanges: false)
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["1", "2"],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: [],
            expectedNumberOfChanges: 1,
            cachePolicy: .returnCacheDataDontFetch(observeChanges: false)
        ),
        TestArgument(
            initialPersistedObjectsIds: ["2", "3"],
            externalDataModelIds: [],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: ["2", "3"],
            expectedNumberOfChanges: 1,
            cachePolicy: .returnCacheDataDontFetch(observeChanges: false)
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: [],
            expectedNumberOfChanges: 1,
            cachePolicy: .returnCacheDataDontFetch(observeChanges: false)
        ),
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: ["0", "1"],
            expectedNumberOfChanges: 1,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false)
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["1", "2"],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: ["1", "2"],
            expectedNumberOfChanges: 1,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false)
        ),
        TestArgument(
            initialPersistedObjectsIds: ["2", "3"],
            externalDataModelIds: [],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: ["2", "3"],
            expectedNumberOfChanges: 1,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false)
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: [],
            expectedNumberOfChanges: 1,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false)
        )/*,
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedCacheResponseDataModelIds: ["0", "1"],
            expectedResponseDataModelIds: ["0", "1", "5", "6", "7", "8", "9"],
            expectedNumberOfChanges: 2,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium)
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["1", "2"],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: ["1", "2"],
            expectedNumberOfChanges: 2,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium)
        ),
        TestArgument(
            initialPersistedObjectsIds: ["2", "3"],
            externalDataModelIds: [],
            expectedCacheResponseDataModelIds: ["2", "3"],
            expectedResponseDataModelIds: ["2", "3"],
            expectedNumberOfChanges: 2,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium)
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: [],
            expectedNumberOfChanges: 2,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium)
        )*/
    ])
    @MainActor func fetchingExternalDataObjectsWhenNotObservingDataChanges(argument: TestArgument) async {
        
        let repositorySync: RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject> = getRepositorySyncFromTestArgument(
            argument: argument
        )
                
        var cancellables: Set<AnyCancellable> = Set()
                
        var sinkCount: Int = 0
        
        var cachedResponseRef: RepositorySyncResponse<MockRepositorySyncDataModel>? // Not recorded or tested if expected changes is 1. ~Levi
        var responseRef: RepositorySyncResponse<MockRepositorySyncDataModel>?
        
        await confirmation(expectedCount: argument.expectedNumberOfChanges) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                repositorySync
                    .getObjectsPublisher(
                        cachePolicy: argument.cachePolicy
                    )
                    .sink { (response: RepositorySyncResponse<MockRepositorySyncDataModel>) in
                        
                        confirmation()
                        
                        sinkCount += 1
                        
                        if argument.expectedNumberOfChanges == 1 {
                            
                            responseRef = response
                            
                            timeoutTask.cancel()
                            continuation.resume(returning: ())
                        }
                        else if sinkCount == 1 {
                            
                            cachedResponseRef = response
                        }
                        else if sinkCount == argument.expectedNumberOfChanges {
                            
                            responseRef = response
                            
                            timeoutTask.cancel()
                            continuation.resume(returning: ())
                        }
                    }
                    .store(in: &cancellables)
            }
        }
        
        cleanUpRepositorySyncFromTestArgument(argument: argument)
        
        if argument.expectedNumberOfChanges > 1 {
            
            let cachedResponseDataModelIds: [String] = sortResponseObjectsDataModelIds(response: cachedResponseRef)
            
            #expect(cachedResponseDataModelIds == argument.initialPersistedObjectsIds)
        }
        
        let responseDataModelIds: [String] = sortResponseObjectsDataModelIds(response: responseRef)
        
        #expect(responseDataModelIds == argument.expectedResponseDataModelIds)
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedCacheResponseDataModelIds: ["0", "1"],
            expectedResponseDataModelIds: ["0", "1", "5", "6", "7", "8", "9"],
            expectedNumberOfChanges: 2,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium)
        )
    ])
    @MainActor func fetchingExternalDataObjectsWhenNotObservingDataChangesCopy(argument: TestArgument) async {
        
        let repositorySync: RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject> = getRepositorySyncFromTestArgument(
            argument: argument
        )
                
        var cancellables: Set<AnyCancellable> = Set()
                
        var sinkCount: Int = 0
        
        var cachedResponseRef: RepositorySyncResponse<MockRepositorySyncDataModel>? // Not recorded or tested if expected changes is 1. ~Levi
        var responseRef: RepositorySyncResponse<MockRepositorySyncDataModel>?
        
        await confirmation(expectedCount: argument.expectedNumberOfChanges) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                repositorySync
                    .getObjectsPublisher(
                        cachePolicy: argument.cachePolicy
                    )
                    .sink { (response: RepositorySyncResponse<MockRepositorySyncDataModel>) in
                        
                        confirmation()
                        
                        sinkCount += 1
                                                
                        if argument.expectedNumberOfChanges == 1 {
                            
                            responseRef = response
                            
                            timeoutTask.cancel()
                            continuation.resume(returning: ())
                        }
                        else if sinkCount == 1 {
                            
                            cachedResponseRef = response
                        }
                        else if sinkCount == argument.expectedNumberOfChanges {
                            
                            responseRef = response
                            
                            timeoutTask.cancel()
                            continuation.resume(returning: ())
                        }
                        
                        print("\n SINK COUNT -> \(sinkCount)")
                        print("   cachedResponseRef: \(sortResponseObjectsDataModelIds(response: cachedResponseRef))")
                        print("   responseRef: \(sortResponseObjectsDataModelIds(response: responseRef))")
                    }
                    .store(in: &cancellables)
            }
        }
        
        cleanUpRepositorySyncFromTestArgument(argument: argument)
        
        if argument.expectedNumberOfChanges > 1 {
            
            let cachedResponseDataModelIds: [String] = sortResponseObjectsDataModelIds(response: cachedResponseRef)
            
            #expect(cachedResponseDataModelIds == argument.expectedCacheResponseDataModelIds)
        }
        
        let responseDataModelIds: [String] = sortResponseObjectsDataModelIds(response: responseRef)
        
        #expect(responseDataModelIds == argument.expectedResponseDataModelIds)
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
     
        let initialObjects: [MockRepositorySyncRealmObject] = argument.initialPersistedObjectsIds.map {
            let object = MockRepositorySyncRealmObject()
            object.id = $0
            object.name = "name" + $0
            return object
        }
        
        let realmDatabase: RealmDatabase = Self.getRealmDatabase(
            fileName: argument.realmFileName,
            addObjects: initialObjects
        )
        
        let externalDataModels: [MockRepositorySyncDataModel] = argument.externalDataModelIds.map {
            MockRepositorySyncDataModel(
                id: $0,
                name: "name " + $0
            )
        }
        
        let externalDataFetch = MockRepositorySyncExternalDataFetch(objects: externalDataModels)
        
        return RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject>(
            externalDataFetch: externalDataFetch,
            realmDatabase: realmDatabase,
            dataModelMapping: MockRepositorySyncMapping()
        )
    }
    
    private func cleanUpRepositorySyncFromTestArgument(argument: TestArgument) {
        
        _ = Self.deleteRealmDatabaseFile(fileName: argument.realmFileName)
    }
}

extension RepositorySyncTests {
    
    private func sortResponseObjectsDataModelIds(response: RepositorySyncResponse<MockRepositorySyncDataModel>?) -> [String] {
        
        let responseObjects: [MockRepositorySyncDataModel] = response?.objects ?? Array()
        
        return responseObjects.map {
            $0.id
        }.sorted {
            $0 < $1
        }
    }
}

// MARK: - Realm Database

extension RepositorySyncTests {
    
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
            databaseConfiguration: Self.getRealmDatabaseConfiguration(fileName: fileName)
        )
        
        _ = realmDatabase.deleteAllObjects()
        
        if addObjects.count > 0 {
            
            let realm: Realm = realmDatabase.openRealm()
            
            do {
                try realm.write {
                    realm.add(addObjects, update: .all)
                }
            }
            catch let error {
                assertionFailure(error.localizedDescription)
            }
        }

        return realmDatabase
    }
}
