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
    
    private static let runTestWaitFor: UInt64 = 3_000_000_000 // 3 seconds
    private static let mockExternalDataFetchDelayRequestForSeconds: TimeInterval = 1
    private static let triggerSecondaryExternalDataFetchWithDelayForSeconds: TimeInterval = 1
    
    struct TestArgument {
        let realmFileName: String = "RepositorySyncTests_" + UUID().uuidString
        let initialPersistedObjectsIds: [String]
        let externalDataModelIds: [String]
        let expectedResponseDataModelIds: [String]
    }
    
    // MARK: - Template
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: [],
            expectedResponseDataModelIds: ["0", "1"]
        )
    ])
    @MainActor func template(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objects,
            cachePolicy: .returnCacheDataDontFetch(observeChanges: false),
            expectedNumberOfChanges: 1,
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
    @MainActor func ignoreCacheDataWillTriggerOnceSinceCacheIsIgnoredAndExternalFetchIsMade(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objects,
            cachePolicy: .fetchIgnoringCacheData(requestPriority: .medium),
            expectedNumberOfChanges: 1,
            expectFirstTriggerIsCacheResponse: false
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedResponseDataModelIds: ["1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["1", "2"],
            expectedResponseDataModelIds: ["1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: ["1", "2", "3"],
            externalDataModelIds: [],
            expectedResponseDataModelIds: ["1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: ["2", "3"],
            externalDataModelIds: [],
            expectedResponseDataModelIds: []
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedResponseDataModelIds: []
        )
    ])
    @MainActor func ignoreCacheDataWillTriggerOnceWithSingleObjectSinceCacheIsIgnoredAndExternalFetchIsMade(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objectId(id: "1"),
            cachePolicy: .fetchIgnoringCacheData(requestPriority: .medium),
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
    @MainActor func returnCacheDataDontFetchWillTriggerOnceWhenCacheDataAlreadyExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objects,
            cachePolicy: .returnCacheDataDontFetch(observeChanges: false),
            expectedNumberOfChanges: 1,
            expectFirstTriggerIsCacheResponse: true
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedResponseDataModelIds: ["1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["1", "2"],
            expectedResponseDataModelIds: []
        ),
        TestArgument(
            initialPersistedObjectsIds: ["1", "2", "3"],
            externalDataModelIds: [],
            expectedResponseDataModelIds: ["1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: ["2", "3"],
            externalDataModelIds: [],
            expectedResponseDataModelIds: []
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedResponseDataModelIds: []
        )
    ])
    @MainActor func returnCacheDataDontFetchWillTriggerOnceWithSingleObjectWhenCacheDataAlreadyExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objectId(id: "1"),
            cachePolicy: .returnCacheDataDontFetch(observeChanges: false),
            expectedNumberOfChanges: 1,
            expectFirstTriggerIsCacheResponse: true
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1", "2"],
            externalDataModelIds: ["5", "4"],
            expectedResponseDataModelIds: ["0", "1", "2", "8"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["3", "2"],
            expectedResponseDataModelIds: ["0", "1", "8"]
        )
    ])
    @MainActor func returnCacheDataDontFetchWillTriggerTwiceWhenObservingChangesOnceForInitialCacheDataAndAgainForSecondaryExternalDataFetch(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objects,
            cachePolicy: .returnCacheDataDontFetch(observeChanges: true),
            expectedNumberOfChanges: 2,
            expectFirstTriggerIsCacheResponse: true,
            triggerSecondaryExternalDataFetchWithIds: ["8", "1", "0"]
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1", "2"],
            externalDataModelIds: ["5", "4"],
            expectedResponseDataModelIds: ["1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["3", "2"],
            expectedResponseDataModelIds: ["1"]
        )
    ])
    @MainActor func returnCacheDataDontFetchWillTriggerTwiceWithSingleObjectWhenObservingChangesOnceForInitialCacheDataAndAgainForSecondaryExternalDataFetch(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objectId(id: "1"),
            cachePolicy: .returnCacheDataDontFetch(observeChanges: true),
            expectedNumberOfChanges: 2,
            expectFirstTriggerIsCacheResponse: true,
            triggerSecondaryExternalDataFetchWithIds: ["8", "1", "0"]
        )
    }
        
    // MARK: - Test Cache Policy (Return Cache Data Else Fetch)
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedResponseDataModelIds: ["0", "1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: ["1", "2"],
            externalDataModelIds: [],
            expectedResponseDataModelIds: ["1", "2"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredOnceWhenCacheDataAlreadyExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objects,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false),
            expectedNumberOfChanges: 1,
            expectFirstTriggerIsCacheResponse: true
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedResponseDataModelIds: ["1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: ["1", "2"],
            externalDataModelIds: [],
            expectedResponseDataModelIds: ["1"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredOnceWithSingleObjectWhenCacheDataAlreadyExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objectId(id: "1"),
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false),
            expectedNumberOfChanges: 1,
            expectFirstTriggerIsCacheResponse: true
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["5", "6", "7"],
            expectedResponseDataModelIds: ["5", "6", "7"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredOnceWhenNoCacheDataExistsAndExternalDataIsFetchedAndNotObservingChanges(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objects,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false),
            expectedNumberOfChanges: 1,
            expectFirstTriggerIsCacheResponse: false
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["5", "6", "7"],
            expectedResponseDataModelIds: ["6"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredOnceWithSingleObjectWhenNoCacheDataExistsAndExternalDataIsFetchedAndNotObservingChanges(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objectId(id: "6"),
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false),
            expectedNumberOfChanges: 1,
            expectFirstTriggerIsCacheResponse: false
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["5", "6", "7"],
            expectedResponseDataModelIds: ["5", "6", "7"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredTwiceWhenNoCacheDataExistsAndExternalDataIsFetchedAndIsObservingChanges(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objects,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 2,
            expectFirstTriggerIsCacheResponse: true
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["5", "6", "7"],
            expectedResponseDataModelIds: ["7"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredTwiceWithSingleObjectWhenNoCacheDataExistsAndExternalDataIsFetchedAndIsObservingChanges(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objectId(id: "7"),
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 2,
            expectFirstTriggerIsCacheResponse: true
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["5", "6", "7"],
            expectedResponseDataModelIds: ["5", "6", "7", "9"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredThreeTimesWhenCacheIsEmptyOnExternalDataFetchAndOnSecondaryExternalDataFetch(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objects,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 3,
            expectFirstTriggerIsCacheResponse: true,
            triggerSecondaryExternalDataFetchWithIds: ["9", "7"]
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["5", "6", "7", "9"],
            expectedResponseDataModelIds: ["9"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredThreeTimesWithSingleObjectWhenCacheIsEmptyOnExternalDataFetchAndOnSecondaryExternalDataFetch(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objectId(id: "9"),
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 3,
            expectFirstTriggerIsCacheResponse: true,
            triggerSecondaryExternalDataFetchWithIds: ["9", "7"]
        )
    }
        
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["1", "2"],
            externalDataModelIds: ["3", "5", "4"],
            expectedResponseDataModelIds: ["1", "2", "7", "9"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredTwiceWhenCacheHasDataAndOnSecondaryExternalDataFetch(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objects,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 2,
            expectFirstTriggerIsCacheResponse: true,
            triggerSecondaryExternalDataFetchWithIds: ["9", "7"]
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["1", "2"],
            externalDataModelIds: ["3", "5", "4"],
            expectedResponseDataModelIds: ["1"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredTwiceWithSingleObjectWhenCacheHasDataAndOnSecondaryExternalDataFetch(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objectId(id: "1"),
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 2,
            expectFirstTriggerIsCacheResponse: true,
            triggerSecondaryExternalDataFetchWithIds: ["1", "7"]
        )
    }
    
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
    @MainActor func returnCacheDataAndFetchWillTriggerOnceWhenNoExternalDataExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objects,
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
    @MainActor func returnCacheDataAndFetchWillTriggerTwiceWhenExternalDataExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objects,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 2,
            expectFirstTriggerIsCacheResponse: true
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["3"],
            expectedResponseDataModelIds: ["3"]
        )
    ])
    @MainActor func returnCacheDataAndFetchWillTriggerTwiceWithSingleObjectWhenExternalDataExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objectId(id: "3"),
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 2,
            expectFirstTriggerIsCacheResponse: true
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["2"],
            expectedResponseDataModelIds: ["0", "1", "2", "5", "9"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["4", "5"],
            expectedResponseDataModelIds: ["4", "5", "9"]
        )
    ])
    @MainActor func returnCacheDataAndFetchWillTriggerThreeTimesOnceForInitialCacheDataForExternalDataFetchAndSecondaryExternalDataFetch(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .objects,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 3,
            expectFirstTriggerIsCacheResponse: true,
            triggerSecondaryExternalDataFetchWithIds: ["9", "5"]
        )
    }
}

// MARK: - Run Test

extension RepositorySyncTests {
    
    @MainActor private func runTest(argument: TestArgument, getObjectsType: RepositorySyncGetObjectsType, cachePolicy: RepositorySyncCachePolicy, expectedNumberOfChanges: Int, expectFirstTriggerIsCacheResponse: Bool, triggerSecondaryExternalDataFetchWithIds: [String] = Array(), loggingEnabled: Bool = false) async {
        
        await runTest(
            realmFileName: argument.realmFileName,
            initialPersistedObjectsIds: argument.initialPersistedObjectsIds,
            externalDataModelIds: argument.externalDataModelIds,
            expectedResponseDataModelIds: argument.expectedResponseDataModelIds,
            getObjectsType: getObjectsType,
            cachePolicy: cachePolicy,
            expectedNumberOfChanges: expectedNumberOfChanges,
            expectFirstTriggerIsCacheResponse: expectFirstTriggerIsCacheResponse,
            triggerSecondaryExternalDataFetchWithIds: triggerSecondaryExternalDataFetchWithIds,
            loggingEnabled: loggingEnabled
        )
    }
    
    @MainActor private func runTest(realmFileName: String, initialPersistedObjectsIds: [String], externalDataModelIds: [String], expectedResponseDataModelIds: [String], getObjectsType: RepositorySyncGetObjectsType, cachePolicy: RepositorySyncCachePolicy, expectedNumberOfChanges: Int, expectFirstTriggerIsCacheResponse: Bool, triggerSecondaryExternalDataFetchWithIds: [String], loggingEnabled: Bool) async {
        
        let repositorySync: RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject> = getRepositorySync(
            realmFileName: realmFileName,
            initialPersistedObjectsIds: initialPersistedObjectsIds,
            externalDataModelIds: externalDataModelIds
        )
        
        let triggersSecondaryExternalDataFetch: Bool = triggerSecondaryExternalDataFetchWithIds.count > 0
        
        var cancellables: Set<AnyCancellable> = Set()
        
        if triggersSecondaryExternalDataFetch {
                        
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.triggerSecondaryExternalDataFetchWithDelayForSeconds) {

                // TODO: See if I can trigger another external data fetch by fetching from mock external data and writing objects to the database. ~Levi
                
                let additionalRepositorySync: RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject> = getRepositorySync(
                    realmFileName: realmFileName,
                    initialPersistedObjectsIds: [],
                    externalDataModelIds: triggerSecondaryExternalDataFetchWithIds
                )
                
                additionalRepositorySync
                    .getObjectsPublisher(getObjectsType: .objects, cachePolicy: .fetchIgnoringCacheData(requestPriority: .medium))
                    .sink { response in
                        if loggingEnabled {
                            print("\n DID SINK SECONDARY DATA FETCH: \(response.objects.map{$0.id})")
                        }
                    }
                    .store(in: &cancellables)
            }
        }
        
        var sinkCount: Int = 0
        
        var cachedResponseRef: RepositorySyncResponse<MockRepositorySyncDataModel>?
        var responseRef: RepositorySyncResponse<MockRepositorySyncDataModel>?
        
        await confirmation(expectedCount: expectedNumberOfChanges) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: Self.runTestWaitFor)
                    if loggingEnabled {
                        print("\n TIMEOUT")
                    }
                    continuation.resume(returning: ())
                }
                
                repositorySync
                    .getObjectsPublisher(
                        getObjectsType: getObjectsType,
                        cachePolicy: cachePolicy
                    )
                    .sink { (response: RepositorySyncResponse<MockRepositorySyncDataModel>) in
                        
                        confirmation()
                        
                        sinkCount += 1
                        
                        if loggingEnabled {
                            print("\n DID SINK")
                            print("  COUNT: \(sinkCount)")
                            print("  RESPONSE: \(response.objects.map{$0.id})")
                        }
                                                
                        if expectFirstTriggerIsCacheResponse && sinkCount == 1 {
                            
                            cachedResponseRef = response
                            
                            if loggingEnabled {
                                print("\n CACHE RECORDED: \(response.objects.map{$0.id})")
                            }
                        }
                        
                        if sinkCount == expectedNumberOfChanges {
                            
                            responseRef = response
                            
                            if loggingEnabled {
                                print("\n RESPONSE RECORDED: \(response.objects.map{$0.id})")
                                print("\n SINK COMPLETE")
                            }
                            
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
            let expectedCachedResponseDataModelIds: [String]
            
            switch getObjectsType {
            case .objects:
                expectedCachedResponseDataModelIds = initialPersistedObjectsIds
            case .objectId(let id):
                if let object = initialPersistedObjectsIds.first(where: {$0 == id}) {
                    expectedCachedResponseDataModelIds = [object]
                }
                else {
                    expectedCachedResponseDataModelIds = []
                }
            }
            
            if loggingEnabled {
                print("\n EXPECT")
                print("  CACHE RESPONSE: \(cachedResponseDataModelIds)")
                print("  TO EQUAL: \(expectedCachedResponseDataModelIds)")
            }
            
            #expect(cachedResponseDataModelIds == expectedCachedResponseDataModelIds)
        }
        
        let responseDataModelIds: [String] = sortResponseObjectsDataModelIds(response: responseRef)
        
        if loggingEnabled {
            print("\n EXPECT")
            print("  RESPONSE: \(responseDataModelIds)")
            print("  TO EQUAL: \(expectedResponseDataModelIds)")
        }
        
        #expect(responseDataModelIds == expectedResponseDataModelIds)
    }
}

// MARK: - Get Repository Sync

extension RepositorySyncTests {
    
    private func getRepositorySync(realmFileName: String, initialPersistedObjectsIds: [String], externalDataModelIds: [String]) -> RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject> {
     
        let initialObjects: [MockRepositorySyncRealmObject] = initialPersistedObjectsIds.map {
            let object = MockRepositorySyncRealmObject()
            object.id = $0
            object.name = "name_" + $0
            return object
        }
        
        let realmDatabase: RealmDatabase = Self.getRealmDatabase(
            fileName: realmFileName,
            addObjects: initialObjects
        )
        
        let externalDataFetch: MockRepositorySyncExternalDataFetch = Self.getMockRepositorySyncExternalDataFetch(
            externalDataModelIds: externalDataModelIds,
            delayRequestSeconds: Self.mockExternalDataFetchDelayRequestForSeconds
        )
        
        return RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject>(
            externalDataFetch: externalDataFetch,
            realmDatabase: realmDatabase,
            dataModelMapping: MockRepositorySyncMapping()
        )
    }
    
    private static func getMockRepositorySyncExternalDataFetch(externalDataModelIds: [String], delayRequestSeconds: TimeInterval) -> MockRepositorySyncExternalDataFetch {
        
        let externalDataModels: [MockRepositorySyncDataModel] = externalDataModelIds.map {
            MockRepositorySyncDataModel(
                id: $0,
                name: "name_" + $0
            )
        }
        
        let externalDataFetch = MockRepositorySyncExternalDataFetch(
            objects: externalDataModels,
            delayRequestSeconds: delayRequestSeconds
        )
        
        return externalDataFetch
    }
}

// MARK: - Sorting Response Object Ids

extension RepositorySyncTests {
    
    private func sortResponseObjectsDataModelIds(response: RepositorySyncResponse<MockRepositorySyncDataModel>?) -> [String] {
        
        let responseObjects: [MockRepositorySyncDataModel] = response?.objects ?? Array()
        let sortedResponseObjects: [MockRepositorySyncDataModel] = responseObjects.sorted {
            $0.id < $1.id
        }
        
        return sortedResponseObjects.map { $0.id }
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
