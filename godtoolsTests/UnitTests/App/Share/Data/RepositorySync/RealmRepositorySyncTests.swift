//
//  RealmRepositorySyncTests.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import Combine
import RealmSwift

struct RealmRepositorySyncTests {
    
    private static let runTestWaitFor: UInt64 = 3_000_000_000 // 3 seconds
    private static let mockExternalDataFetchDelayRequestForSeconds: TimeInterval = 1
    private static let triggerSecondaryExternalDataFetchWithDelayForSeconds: TimeInterval = 1
    private static let namePrefix: String = "name_"
    
    struct TestArgument {
        let realmFileName: String = "RealmRepositorySyncTests_" + UUID().uuidString
        let initialPersistedObjectsIds: [String]
        let externalDataModelIds: [String]
        let expectedCachedResponseDataModelIds: [String]?
        let expectedResponseDataModelIds: [String]
    }
    
    // MARK: - Template
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: [],
            expectedCachedResponseDataModelIds: ["0", "1"],
            expectedResponseDataModelIds: ["0", "1"]
        )
    ])
    @MainActor func template(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataDontFetch(observeChanges: false),
            expectedNumberOfChanges: 1
        )
    }
    
    // MARK: - Test Cache Policy (Ignoring Cache Data) - Objects
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedCachedResponseDataModelIds: nil,
            expectedResponseDataModelIds: ["0", "1", "5", "6", "7", "8", "9"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["1", "2"],
            expectedCachedResponseDataModelIds: nil,
            expectedResponseDataModelIds: ["1", "2"]
        ),
        TestArgument(
            initialPersistedObjectsIds: ["2", "3"],
            externalDataModelIds: [],
            expectedCachedResponseDataModelIds: nil,
            expectedResponseDataModelIds: ["2", "3"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedCachedResponseDataModelIds: nil,
            expectedResponseDataModelIds: []
        )
    ])
    @MainActor func ignoreCacheDataWillTriggerOnceSinceCacheIsIgnoredAndExternalFetchIsMade(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .fetchIgnoringCacheData(requestPriority: .medium),
            expectedNumberOfChanges: 1
        )
    }
    
    // MARK: - Test Cache Policy (Ignoring Cache Data) - Object ID
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedCachedResponseDataModelIds: nil,
            expectedResponseDataModelIds: ["1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["1", "2"],
            expectedCachedResponseDataModelIds: nil,
            expectedResponseDataModelIds: ["1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: ["1", "2", "3"],
            externalDataModelIds: [],
            expectedCachedResponseDataModelIds: nil,
            expectedResponseDataModelIds: ["1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: ["2", "3"],
            externalDataModelIds: [],
            expectedCachedResponseDataModelIds: nil,
            expectedResponseDataModelIds: []
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedCachedResponseDataModelIds: nil,
            expectedResponseDataModelIds: []
        )
    ])
    @MainActor func ignoreCacheDataWillTriggerOnceWithSingleObjectSinceCacheIsIgnoredAndExternalFetchIsMade(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .object(id: "1"),
            cachePolicy: .fetchIgnoringCacheData(requestPriority: .medium),
            expectedNumberOfChanges: 1
        )
    }
    
    // MARK: - Test Cache Policy (Ignoring Cache Data) - Objects With Query
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedCachedResponseDataModelIds: nil,
            expectedResponseDataModelIds: ["5"]
        )
    ])
    @MainActor func ignoreCacheDataWillFilter(argument: TestArgument) async {
        
        let filter = NSPredicate(format: "\(#keyPath(MockRepositorySyncRealmObject.name)) == %@", Self.namePrefix + "5")
        
        await runTest(
            argument: argument,
            getObjectsType: .objectsWithQuery(databaseQuery: RealmDatabaseQuery.filter(filter: filter)),
            cachePolicy: .fetchIgnoringCacheData(requestPriority: .medium),
            expectedNumberOfChanges: 1,
            loggingEnabled: false
        )
    }
    
    // MARK: - Test Cache Policy (Return Cache Data Don't Fetch) - Objects
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedCachedResponseDataModelIds: ["0", "1"],
            expectedResponseDataModelIds: ["0", "1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["1", "2"],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: []
        ),
        TestArgument(
            initialPersistedObjectsIds: ["2", "3"],
            externalDataModelIds: [],
            expectedCachedResponseDataModelIds: ["2", "3"],
            expectedResponseDataModelIds: ["2", "3"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: []
        )
    ])
    @MainActor func returnCacheDataDontFetchWillTriggerOnceWhenCacheDataAlreadyExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataDontFetch(observeChanges: false),
            expectedNumberOfChanges: 1
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1", "2"],
            externalDataModelIds: ["5", "4"],
            expectedCachedResponseDataModelIds: ["0", "1", "2"],
            expectedResponseDataModelIds: ["0", "1", "2", "8"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["3", "2"],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: ["0", "1", "8"]
        )
    ])
    @MainActor func returnCacheDataDontFetchWillTriggerTwiceWhenObservingChangesOnceForInitialCacheDataAndAgainForSecondaryExternalDataFetch(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataDontFetch(observeChanges: true),
            expectedNumberOfChanges: 2,
            triggerSecondaryExternalDataFetchWithIds: ["8", "1", "0"]
        )
    }
    
    // MARK: - Test Cache Policy (Return Cache Data Don't Fetch) - Object ID
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedCachedResponseDataModelIds: ["1"],
            expectedResponseDataModelIds: ["1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["1", "2"],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: []
        ),
        TestArgument(
            initialPersistedObjectsIds: ["1", "2", "3"],
            externalDataModelIds: [],
            expectedCachedResponseDataModelIds: ["1"],
            expectedResponseDataModelIds: ["1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: ["2", "3"],
            externalDataModelIds: [],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: []
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: []
        )
    ])
    @MainActor func returnCacheDataDontFetchWillTriggerOnceWithSingleObjectWhenCacheDataAlreadyExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .object(id: "1"),
            cachePolicy: .returnCacheDataDontFetch(observeChanges: false),
            expectedNumberOfChanges: 1
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1", "2"],
            externalDataModelIds: ["5", "4"],
            expectedCachedResponseDataModelIds: ["1"],
            expectedResponseDataModelIds: ["1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["3", "2"],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: ["1"]
        )
    ])
    @MainActor func returnCacheDataDontFetchWillTriggerTwiceWithSingleObjectWhenObservingChangesOnceForInitialCacheDataAndAgainForSecondaryExternalDataFetch(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .object(id: "1"),
            cachePolicy: .returnCacheDataDontFetch(observeChanges: true),
            expectedNumberOfChanges: 2,
            triggerSecondaryExternalDataFetchWithIds: ["8", "1", "0"]
        )
    }
        
    // MARK: - Test Cache Policy (Return Cache Data Else Fetch) - Objects
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedCachedResponseDataModelIds: ["0", "1"],
            expectedResponseDataModelIds: ["0", "1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: ["1", "2"],
            externalDataModelIds: [],
            expectedCachedResponseDataModelIds: ["1", "2"],
            expectedResponseDataModelIds: ["1", "2"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredOnceWhenCacheDataAlreadyExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false),
            expectedNumberOfChanges: 1
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["5", "6", "7"],
            expectedCachedResponseDataModelIds: nil,
            expectedResponseDataModelIds: ["5", "6", "7"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredOnceWhenNoCacheDataExistsAndExternalDataIsFetchedAndNotObservingChanges(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false),
            expectedNumberOfChanges: 1
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["5", "6", "7"],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: ["5", "6", "7"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredTwiceWhenNoCacheDataExistsAndExternalDataIsFetchedAndIsObservingChanges(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 2
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["5", "6", "7"],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: ["5", "6", "7", "9"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredThreeTimesWhenCacheIsEmptyOnExternalDataFetchAndOnSecondaryExternalDataFetch(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 3,
            triggerSecondaryExternalDataFetchWithIds: ["9", "7"]
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["1", "2"],
            externalDataModelIds: ["3", "5", "4"],
            expectedCachedResponseDataModelIds: ["1", "2"],
            expectedResponseDataModelIds: ["1", "2", "7", "9"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredTwiceWhenCacheHasDataAndOnSecondaryExternalDataFetch(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 2,
            triggerSecondaryExternalDataFetchWithIds: ["9", "7"]
        )
    }
    
    // MARK: - Test Cache Policy (Return Cache Data Else Fetch) - Object ID
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedCachedResponseDataModelIds: ["1"],
            expectedResponseDataModelIds: ["1"]
        ),
        TestArgument(
            initialPersistedObjectsIds: ["1", "2"],
            externalDataModelIds: [],
            expectedCachedResponseDataModelIds: ["1"],
            expectedResponseDataModelIds: ["1"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredOnceWithSingleObjectWhenCacheDataAlreadyExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .object(id: "1"),
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false),
            expectedNumberOfChanges: 1
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["5", "6", "7"],
            expectedCachedResponseDataModelIds: nil,
            expectedResponseDataModelIds: ["6"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredOnceWithSingleObjectWhenNoCacheDataExistsAndExternalDataIsFetchedAndNotObservingChanges(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .object(id: "6"),
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false),
            expectedNumberOfChanges: 1
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["5", "6", "7"],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: ["7"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredTwiceWithSingleObjectWhenNoCacheDataExistsAndExternalDataIsFetchedAndIsObservingChanges(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .object(id: "7"),
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 2
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["5", "6", "7", "9"],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: ["9"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredThreeTimesWithSingleObjectWhenCacheIsEmptyOnExternalDataFetchAndOnSecondaryExternalDataFetch(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .object(id: "9"),
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 3,
            triggerSecondaryExternalDataFetchWithIds: ["9", "7"]
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["1", "2"],
            externalDataModelIds: ["3", "5", "4"],
            expectedCachedResponseDataModelIds: ["1"],
            expectedResponseDataModelIds: ["1"]
        )
    ])
    @MainActor func returnCacheDataElseFetchIsTriggeredTwiceWithSingleObjectWhenCacheHasDataAndOnSecondaryExternalDataFetch(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .object(id: "1"),
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 2,
            triggerSecondaryExternalDataFetchWithIds: ["1", "7"]
        )
    }
    
    // MARK: - Test Cache Policy (Return Cache Data And Fetch) - Objects
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: [],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: []
        ),
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: [],
            expectedCachedResponseDataModelIds: ["0", "1"],
            expectedResponseDataModelIds: ["0", "1"]
        )
    ])
    @MainActor func returnCacheDataAndFetchWillTriggerOnceWhenNoExternalDataExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 1
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["2"],
            expectedCachedResponseDataModelIds: ["0", "1"],
            expectedResponseDataModelIds: ["0", "1", "2"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["4", "5"],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: ["4", "5"]
        )
    ])
    @MainActor func returnCacheDataAndFetchWillTriggerTwiceWhenExternalDataExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 2
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["2"],
            expectedCachedResponseDataModelIds: ["0", "1"],
            expectedResponseDataModelIds: ["0", "1", "2", "5", "9"]
        ),
        TestArgument(
            initialPersistedObjectsIds: [],
            externalDataModelIds: ["4", "5"],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: ["4", "5", "9"]
        )
    ])
    @MainActor func returnCacheDataAndFetchWillTriggerThreeTimesOnceForInitialCacheDataForExternalDataFetchAndSecondaryExternalDataFetch(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 3,
            triggerSecondaryExternalDataFetchWithIds: ["9", "5"]
        )
    }
    
    // MARK: - Test Cache Policy (Return Cache Data And Fetch) - Object ID
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["3"],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: ["3"]
        )
    ])
    @MainActor func returnCacheDataAndFetchWillTriggerTwiceWithSingleObjectWhenExternalDataExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .object(id: "3"),
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 2
        )
    }
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: [],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: ["3"]
        ),
        TestArgument(
            initialPersistedObjectsIds: ["0", "1"],
            externalDataModelIds: ["5"],
            expectedCachedResponseDataModelIds: [],
            expectedResponseDataModelIds: ["3"]
        )
    ])
    @MainActor func returnCacheDataAndFetchWillTriggerTwiceWithSingleObjectWhenAdditionalDataExists(argument: TestArgument) async {
        
        await runTest(
            argument: argument,
            getObjectsType: .object(id: "3"),
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 2,
            triggerSecondaryExternalDataFetchWithIds: ["3"]
        )
    }
    
    // MARK: - Test Cache Policy (Return Cache Data And Fetch) - Objects With Query
    
    @Test(arguments: [
        TestArgument(
            initialPersistedObjectsIds: ["0", "1", "5"],
            externalDataModelIds: ["5", "6", "7", "8", "9"],
            expectedCachedResponseDataModelIds: ["5"],
            expectedResponseDataModelIds: ["5"]
        )
    ])
    @MainActor func returnCacheDataAndFetchWillFilter(argument: TestArgument) async {
        
        let filter = NSPredicate(format: "\(#keyPath(MockRepositorySyncRealmObject.name)) == %@", Self.namePrefix + "5")
        
        await runTest(
            argument: argument,
            getObjectsType: .objectsWithQuery(databaseQuery: RealmDatabaseQuery.filter(filter: filter)),
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 2,
            loggingEnabled: true
        )
    }
    
    // MARK: - Test Fetching Cached Objects
    
    @Test()
    @MainActor func returnsObjectsByIds() async {
        
        let realmFileName: String = UUID().uuidString
        
        let repositorySync: RealmRepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject> = getRepositorySync(
            realmFileName: realmFileName,
            initialPersistedObjectsIds: ["5", "3", "2", "1", "4", "0", "6"],
            externalDataModelIds: []
        )
        
        let ids: [String] = ["0", "1", "2"]
        let dataModels: [MockRepositorySyncDataModel] = repositorySync.getCachedObjects(ids: ids)
        
        _ = Self.deleteRealmDatabaseFile(fileName: realmFileName)
        
        #expect(ids.count == dataModels.count)
        #expect(dataModels.count(where: {$0.id == "0"}) == 1)
        #expect(dataModels.count(where: {$0.id == "1"}) == 1)
        #expect(dataModels.count(where: {$0.id == "2"}) == 1)
    }
    
    // MARK: - Test Sync External Data Fetch Response
    
    @Test()
    @MainActor func deletesObjectsNotFoundInExternalDataFetch() async {
        
        let realmFileName: String = UUID().uuidString
        
        let initialPersistedObjectsIds: [String] = ["5", "3", "2", "1", "4", "0", "6"]
        let externalDataModelIds: [String] = ["2", "1", "6", "7"]
        
        let repositorySync: RealmRepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject> = getRepositorySync(
            realmFileName: realmFileName,
            initialPersistedObjectsIds: initialPersistedObjectsIds,
            externalDataModelIds: externalDataModelIds
        )
        
        let mockExternalDataFetch = Self.getMockRepositorySyncExternalDataFetch(
            externalDataModelIds: externalDataModelIds,
            delayRequestSeconds: 0.1
        )
        
        let initialCachedObjectsIds: [String] = repositorySync.getCachedObjects().map { $0.id }
        #expect(initialCachedObjectsIds.count == initialPersistedObjectsIds.count)
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var sinkCount: Int = 0
    
        await confirmation(expectedCount: 1) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                mockExternalDataFetch
                    .getObjectsPublisher(requestPriority: .high)
                    .flatMap { (externalFetchResponse: RepositorySyncResponse<MockRepositorySyncDataModel>) in
                                                
                        let response = repositorySync.syncExternalDataFetchResponse(
                            response: externalFetchResponse
                        )
                        
                        return Just(response)
                            .eraseToAnyPublisher()
                    }
                    .sink { (response: RepositorySyncResponse<MockRepositorySyncDataModel>) in
                                                
                        // Place inside a sink or other async closure:
                        confirmation()
                        
                        sinkCount += 1
                        
                        if sinkCount == 1 {
                            
                            timeoutTask.cancel()
                            continuation.resume(returning: ())
                        }
                    }
                    .store(in: &cancellables)
            }
        }
                
        let cachedObjectsIds: [String] = repositorySync.getCachedObjects().map { $0.id }
                
        #expect(cachedObjectsIds.count == externalDataModelIds.count)
        
        for id in externalDataModelIds {
            #expect(cachedObjectsIds.contains(id))
        }
        
        _ = Self.deleteRealmDatabaseFile(fileName: realmFileName)
    }
}

// MARK: - Run Test

extension RealmRepositorySyncTests {
    
    @MainActor private func runTest(argument: TestArgument, getObjectsType: RealmRepositorySyncGetObjectsType, cachePolicy: RepositorySyncCachePolicy, expectedNumberOfChanges: Int, triggerSecondaryExternalDataFetchWithIds: [String] = Array(), loggingEnabled: Bool = false) async {
        
        await runTest(
            realmFileName: argument.realmFileName,
            initialPersistedObjectsIds: argument.initialPersistedObjectsIds,
            externalDataModelIds: argument.externalDataModelIds,
            expectedCachedResponseDataModelIds: argument.expectedCachedResponseDataModelIds,
            expectedResponseDataModelIds: argument.expectedResponseDataModelIds,
            getObjectsType: getObjectsType,
            cachePolicy: cachePolicy,
            expectedNumberOfChanges: expectedNumberOfChanges,
            triggerSecondaryExternalDataFetchWithIds: triggerSecondaryExternalDataFetchWithIds,
            loggingEnabled: loggingEnabled
        )
    }
    
    @MainActor private func runTest(realmFileName: String, initialPersistedObjectsIds: [String], externalDataModelIds: [String], expectedCachedResponseDataModelIds: [String]?, expectedResponseDataModelIds: [String], getObjectsType: RealmRepositorySyncGetObjectsType, cachePolicy: RepositorySyncCachePolicy, expectedNumberOfChanges: Int, triggerSecondaryExternalDataFetchWithIds: [String], loggingEnabled: Bool) async {
        
        let repositorySync: RealmRepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject> = getRepositorySync(
            realmFileName: realmFileName,
            initialPersistedObjectsIds: initialPersistedObjectsIds,
            externalDataModelIds: externalDataModelIds
        )
        
        let triggersSecondaryExternalDataFetch: Bool = triggerSecondaryExternalDataFetchWithIds.count > 0
        
        var cancellables: Set<AnyCancellable> = Set()
        
        if triggersSecondaryExternalDataFetch {
                        
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.triggerSecondaryExternalDataFetchWithDelayForSeconds) {

                // TODO: See if I can trigger another external data fetch by fetching from mock external data and writing objects to the database. ~Levi
                
                if loggingEnabled {
                    print("\n PERFORMING SECONDARY EXTERNAL DATA FETCH")
                }
                
                let additionalRepositorySync: RealmRepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject> = getRepositorySync(
                    realmFileName: realmFileName,
                    initialPersistedObjectsIds: [],
                    externalDataModelIds: triggerSecondaryExternalDataFetchWithIds
                )
                
                additionalRepositorySync
                    .getObjectsPublisher(getObjectsType: .allObjects, cachePolicy: .fetchIgnoringCacheData(requestPriority: .medium))
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
                                                
                        if sinkCount == 1 && expectedCachedResponseDataModelIds != nil {
                            
                            cachedResponseRef = response
                            
                            if loggingEnabled {
                                print("\n CACHE RESPONSE RECORDED: \(response.objects.map{$0.id})")
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
        
        if let expectedCachedResponseDataModelIds = expectedCachedResponseDataModelIds {
            
            let cachedResponseDataModelIds: [String] = sortResponseObjectsDataModelIds(response: cachedResponseRef)
                        
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

extension RealmRepositorySyncTests {
    
    private func getRepositorySync(realmFileName: String, initialPersistedObjectsIds: [String], externalDataModelIds: [String]) -> RealmRepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject> {
     
        let initialObjects: [MockRepositorySyncRealmObject] = initialPersistedObjectsIds.map {
            let object = MockRepositorySyncRealmObject()
            object.id = $0
            object.name = Self.namePrefix + $0
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
        
        return RealmRepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch, MockRepositorySyncRealmObject>(
            externalDataFetch: externalDataFetch,
            realmDatabase: realmDatabase,
            dataModelMapping: MockRealmRepositorySyncMapping()
        )
    }
    
    private static func getMockRepositorySyncExternalDataFetch(externalDataModelIds: [String], delayRequestSeconds: TimeInterval) -> MockRepositorySyncExternalDataFetch {
        
        let externalDataModels: [MockRepositorySyncDataModel] = externalDataModelIds.map {
            MockRepositorySyncDataModel(
                id: $0,
                name: Self.namePrefix + $0
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

extension RealmRepositorySyncTests {
    
    private func sortResponseObjectsDataModelIds(response: RepositorySyncResponse<MockRepositorySyncDataModel>?) -> [String] {
        
        let responseObjects: [MockRepositorySyncDataModel] = response?.objects ?? Array()
        let sortedResponseObjects: [MockRepositorySyncDataModel] = responseObjects.sorted {
            $0.id < $1.id
        }
        
        return sortedResponseObjects.map { $0.id }
    }
}

// MARK: - Realm Database

extension RealmRepositorySyncTests {
    
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
