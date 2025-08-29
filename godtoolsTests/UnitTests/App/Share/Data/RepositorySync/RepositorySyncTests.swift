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
    
    private static let runTestWaitFor: UInt64 = 2_000_000_000 // 2 seconds
    private static let mockExternalDataFetchDelayRequestForSeconds: TimeInterval = 1
    
    struct TestArgument {
        let realmFileName: String = "RepositorySyncTests_" + UUID().uuidString
        let initialPersistedObjectsIds: [String]
        let externalDataModelIds: [String]
        let expectedResponseDataModelIds: [String]
    }
    
    // MARK: - Template
    
    @Test(arguments: [

    ])
    @MainActor func template(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 2,
            expectFirstTriggerIsCacheResponse: true
        )
    }
    
    // MARK: - Test Cache Policy (Ignoring Cache Data)
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedResponseDataModelIds: ["0", "1", "5", "6", "7", "8", "9"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["1", "2"],
            expectedResponseDataModelIds: ["1", "2"]
        ),
        TestArgument(
            initialPersistedObjectsIds: ["2", "3"],
            externalDataModelIds: [],
            expectedResponseDataModelIds: ["2", "3"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedResponseDataModelIds: []
        )
    ])
    @MainActor func ignoreCacheDataWillTriggerOnceWhenNotObservingDataChanges(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            cachePolicy: .fetchIgnoringCacheData(requestPriority: .medium, observeChanges: false),
            expectedNumberOfChanges: 1,
            expectFirstTriggerIsCacheResponse: false
        )
    }
    
    // MARK: - Test Cache Policy (Return Cache Data Don't Fetch)
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedResponseDataModelIds: ["0", "1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["1", "2"],
            expectedResponseDataModelIds: []
        ),
        TestArgument(
            initialPersistedObjectsIds: ["2", "3"],
            externalDataModelIds: [],
            expectedResponseDataModelIds: ["2", "3"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedResponseDataModelIds: []
        )
    ])
    @MainActor func cacheDataDontFetchWillTriggerOnceWhenNoExternalDataIsWritten(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            cachePolicy: .returnCacheDataDontFetch(observeChanges: false),
            expectedNumberOfChanges: 1,
            expectFirstTriggerIsCacheResponse: true
        )
    }
    
    // MARK: - Test Cache Policy (Return Cache Data Else Fetch)
    
    // MARK: - Test Cache Policy (Cache Data And Fetch)
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedResponseDataModelIds: []
        ),
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: [],
            expectedResponseDataModelIds: ["0", "1"]
        )
    ])
    @MainActor func cacheDataAndFetchWillTriggerOnceWhenNoExternalDataExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 1,
            expectFirstTriggerIsCacheResponse: true
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["2"],
            expectedResponseDataModelIds: ["0", "1", "2"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["4", "5"],
            expectedResponseDataModelIds: ["4", "5"]
        )
    ])
    @MainActor func cacheDataAndFetchWillTriggerTwiceWhenExternalDataExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 2,
            expectFirstTriggerIsCacheResponse: true
        )
    }
    
    
    /*
    
    @Test(arguments: [
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
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedCacheResponseDataModelIds: [],
            expectedResponseDataModelIds: [],
            expectedNumberOfChanges: 1,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium)
        )
    ])
    @MainActor func ignoreCachePolicyTriggeredTwiceWhenObservingDataChanges(argument: TestArgument) async {
        
        
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
    }*/
}

// MARK: - Shared Run Test

extension RepositorySyncTests {
    
    @MainActor private func runTest(argument: TestArgument, cachePolicy: RepositorySyncCachePolicy, expectedNumberOfChanges: Int, expectFirstTriggerIsCacheResponse: Bool) async {
        
        await runTest(
            realmFileName: argument.realmFileName,
            initialPersistedObjectsIds: argument.initialPersistedObjectsIds,
            externalDataModelIds: argument.externalDataModelIds,
            expectedResponseDataModelIds: argument.expectedResponseDataModelIds,
            cachePolicy: cachePolicy,
            expectedNumberOfChanges: expectedNumberOfChanges,
            expectFirstTriggerIsCacheResponse: expectFirstTriggerIsCacheResponse
        )
    }
    
    @MainActor private func runTest(realmFileName: String, initialPersistedObjectsIds: [String], externalDataModelIds: [String], expectedResponseDataModelIds: [String], cachePolicy: RepositorySyncCachePolicy, expectedNumberOfChanges: Int, expectFirstTriggerIsCacheResponse: Bool) async {
        
        let repositorySync: RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject> = getRepositorySync(
            realmFileName: realmFileName,
            initialPersistedObjectsIds: initialPersistedObjectsIds,
            externalDataModelIds: externalDataModelIds
        )
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var sinkCount: Int = 0
        
        var cachedResponseRef: RepositorySyncResponse<MockRepositorySyncDataModel>?
        var responseRef: RepositorySyncResponse<MockRepositorySyncDataModel>?
        
        await confirmation(expectedCount: expectedNumberOfChanges) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: Self.runTestWaitFor)
                    continuation.resume(returning: ())
                }
                
                repositorySync
                    .getObjectsPublisher(
                        cachePolicy: cachePolicy
                    )
                    .sink { (response: RepositorySyncResponse<MockRepositorySyncDataModel>) in
                        
                        confirmation()
                        
                        sinkCount += 1
                        
                        if expectFirstTriggerIsCacheResponse && sinkCount == 1 {
                            
                            cachedResponseRef = response
                        }
                        
                        if sinkCount == expectedNumberOfChanges {
                            
                            responseRef = response
                            
                            timeoutTask.cancel()
                            continuation.resume(returning: ())
                        }
                    }
                    .store(in: &cancellables)
            }
        }
        
        _ = Self.deleteRealmDatabaseFile(fileName: realmFileName)
        
        if expectFirstTriggerIsCacheResponse {
            
            let cachedResponseDataModelIds: [String] = sortResponseObjectsDataModelIds(response: cachedResponseRef)
            
            #expect(cachedResponseDataModelIds == initialPersistedObjectsIds)
        }
        
        let responseDataModelIds: [String] = sortResponseObjectsDataModelIds(response: responseRef)
        
        #expect(responseDataModelIds == expectedResponseDataModelIds)
    }
}

// MARK: - Get Repository Sync

extension RepositorySyncTests {
    
    private func getRepositorySync(realmFileName: String, initialPersistedObjectsIds: [String], externalDataModelIds: [String]) -> RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject> {
     
        let initialObjects: [MockRepositorySyncRealmObject] = initialPersistedObjectsIds.map {
            let object = MockRepositorySyncRealmObject()
            object.id = $0
            object.name = "name" + $0
            return object
        }
        
        let realmDatabase: RealmDatabase = Self.getRealmDatabase(
            fileName: realmFileName,
            addObjects: initialObjects
        )
        
        let externalDataModels: [MockRepositorySyncDataModel] = externalDataModelIds.map {
            MockRepositorySyncDataModel(
                id: $0,
                name: "name " + $0
            )
        }
        
        let externalDataFetch = MockRepositorySyncExternalDataFetch(
            objects: externalDataModels,
            delayRequestSeconds: Self.mockExternalDataFetchDelayRequestForSeconds
        )
        
        return RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject>(
            externalDataFetch: externalDataFetch,
            realmDatabase: realmDatabase,
            dataModelMapping: MockRepositorySyncMapping()
        )
    }
}

// MARK: - Sorting Response Object Ids

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
