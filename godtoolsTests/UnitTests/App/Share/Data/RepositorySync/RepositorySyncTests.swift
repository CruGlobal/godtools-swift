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
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: [],
            expectedNumberOfChanges: 1,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium)
        ),
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: [],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: ["0", "1"],
            expectedNumberOfChanges: 1,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium)
        ),
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["2"],
            expectedCacheResponseDataModelIds: ["0", "1"],
            expectedResponseDataModelIds: ["0", "1", "2"],
            expectedNumberOfChanges: 2,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium)
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["0", "1"],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: ["0", "1"],
            expectedNumberOfChanges: 2,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium)
        )
    ])
    @MainActor func numberOfChangesTriggered(argument: TestArgument) async {
        
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
                    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
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
        )
    ])
    @MainActor func fetchingExternalDataObjectsWhenNotObservingDataChanges(argument: TestArgument) async {
        
        let repositorySync: RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject> = getRepositorySyncFromTestArgument(
            argument: argument
        )
                
        var cancellables: Set<AnyCancellable> = Set()
                
        var sinkCount: Int = 0
        
        var responseRef: RepositorySyncResponse<MockRepositorySyncDataModel>?
        
        await confirmation(expectedCount: argument.expectedNumberOfChanges) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                    continuation.resume(returning: ())
                }
                
                repositorySync
                    .getObjectsPublisher(
                        cachePolicy: argument.cachePolicy
                    )
                    .sink { (response: RepositorySyncResponse<MockRepositorySyncDataModel>) in
                        
                        confirmation()
                        
                        sinkCount += 1
                        
                        if sinkCount == 1 {
                            
                            responseRef = response
                            
                            timeoutTask.cancel()
                            continuation.resume(returning: ())
                        }
                    }
                    .store(in: &cancellables)
            }
        }
        
        cleanUpRepositorySyncFromTestArgument(argument: argument)
        
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
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: ["2", "3"],
            expectedNumberOfChanges: 1,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium)
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: [],
            expectedNumberOfChanges: 1,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium)
        )
    ])
    @MainActor func fetchingExternalDataObjectsWhenObservingDataChanges(argument: TestArgument) async {
        
        let repositorySync: RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject> = getRepositorySyncFromTestArgument(
            argument: argument
        )
                
        var cancellables: Set<AnyCancellable> = Set()
                
        var sinkCount: Int = 0
        
        var cachedResponseRef: RepositorySyncResponse<MockRepositorySyncDataModel>?
        var responseRef: RepositorySyncResponse<MockRepositorySyncDataModel>?
        
        await confirmation(expectedCount: argument.expectedNumberOfChanges) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
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
                            
                            cachedResponseRef = response
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
