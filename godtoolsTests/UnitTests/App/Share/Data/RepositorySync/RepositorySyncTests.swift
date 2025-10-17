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
import SwiftData

struct RepositorySyncTests {
    
    private static let runTestWaitFor: UInt64 = 3_000_000_000 // 3 seconds
    private static let mockExternalDataFetchDelayRequestForSeconds: TimeInterval = 1
    private static let triggerSecondaryExternalDataFetchWithDelayForSeconds: TimeInterval = 1
    private static let namePrefix: String = "name_"
    
    struct TestArgument {
        let realmFileName: String = "RepositorySyncTests_realm_" + UUID().uuidString
        let swiftDatabaseName: String = "RepositorySyncTests_swift_" + UUID().uuidString
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataDontFetch(observeChanges: false),
            expectedNumberOfChanges: 1
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .allObjects,
                cachePolicy: .returnCacheDataDontFetch(observeChanges: false),
                expectedNumberOfChanges: 1
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .fetchIgnoringCacheData(requestPriority: .medium),
            expectedNumberOfChanges: 1
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .allObjects,
                cachePolicy: .fetchIgnoringCacheData(requestPriority: .medium),
                expectedNumberOfChanges: 1
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .object(id: "1"),
            cachePolicy: .fetchIgnoringCacheData(requestPriority: .medium),
            expectedNumberOfChanges: 1
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .object(id: "1"),
                cachePolicy: .fetchIgnoringCacheData(requestPriority: .medium),
                expectedNumberOfChanges: 1
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataDontFetch(observeChanges: false),
            expectedNumberOfChanges: 1
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .allObjects,
                cachePolicy: .returnCacheDataDontFetch(observeChanges: false),
                expectedNumberOfChanges: 1
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataDontFetch(observeChanges: true),
            expectedNumberOfChanges: 2,
            triggerSecondaryExternalDataFetchWithIds: ["8", "1", "0"]
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .allObjects,
                cachePolicy: .returnCacheDataDontFetch(observeChanges: true),
                expectedNumberOfChanges: 2,
                triggerSecondaryExternalDataFetchWithIds: ["8", "1", "0"]
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .object(id: "1"),
            cachePolicy: .returnCacheDataDontFetch(observeChanges: false),
            expectedNumberOfChanges: 1
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .object(id: "1"),
                cachePolicy: .returnCacheDataDontFetch(observeChanges: false),
                expectedNumberOfChanges: 1
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .object(id: "1"),
            cachePolicy: .returnCacheDataDontFetch(observeChanges: true),
            expectedNumberOfChanges: 2,
            triggerSecondaryExternalDataFetchWithIds: ["8", "1", "0"]
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .object(id: "1"),
                cachePolicy: .returnCacheDataDontFetch(observeChanges: true),
                expectedNumberOfChanges: 2,
                triggerSecondaryExternalDataFetchWithIds: ["8", "1", "0"]
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false),
            expectedNumberOfChanges: 1
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .allObjects,
                cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false),
                expectedNumberOfChanges: 1
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false),
            expectedNumberOfChanges: 1
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .allObjects,
                cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false),
                expectedNumberOfChanges: 1
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 2
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .allObjects,
                cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
                expectedNumberOfChanges: 2
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 3,
            triggerSecondaryExternalDataFetchWithIds: ["9", "7"]
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .allObjects,
                cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
                expectedNumberOfChanges: 3,
                triggerSecondaryExternalDataFetchWithIds: ["9", "7"]
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 2,
            triggerSecondaryExternalDataFetchWithIds: ["9", "7"]
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .allObjects,
                cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
                expectedNumberOfChanges: 2,
                triggerSecondaryExternalDataFetchWithIds: ["9", "7"]
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .object(id: "1"),
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false),
            expectedNumberOfChanges: 1
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .object(id: "1"),
                cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false),
                expectedNumberOfChanges: 1
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .object(id: "6"),
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false),
            expectedNumberOfChanges: 1
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .object(id: "6"),
                cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: false),
                expectedNumberOfChanges: 1
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .object(id: "7"),
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 2
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .object(id: "7"),
                cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
                expectedNumberOfChanges: 2
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .object(id: "9"),
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 3,
            triggerSecondaryExternalDataFetchWithIds: ["9", "7"]
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .object(id: "9"),
                cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
                expectedNumberOfChanges: 3,
                triggerSecondaryExternalDataFetchWithIds: ["9", "7"]
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .object(id: "1"),
            cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
            expectedNumberOfChanges: 2,
            triggerSecondaryExternalDataFetchWithIds: ["1", "7"]
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .object(id: "1"),
                cachePolicy: .returnCacheDataElseFetch(requestPriority: .medium, observeChanges: true),
                expectedNumberOfChanges: 2,
                triggerSecondaryExternalDataFetchWithIds: ["1", "7"]
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 1
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .allObjects,
                cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
                expectedNumberOfChanges: 1
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 2
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .allObjects,
                cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
                expectedNumberOfChanges: 2
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .allObjects,
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 3,
            triggerSecondaryExternalDataFetchWithIds: ["9", "5"]
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .allObjects,
                cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
                expectedNumberOfChanges: 3,
                triggerSecondaryExternalDataFetchWithIds: ["9", "5"]
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .object(id: "3"),
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 2
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .object(id: "3"),
                cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
                expectedNumberOfChanges: 2
            )
        }
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
        
        await runRealmTest(
            argument: argument,
            getObjectsType: .object(id: "3"),
            cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
            expectedNumberOfChanges: 2,
            triggerSecondaryExternalDataFetchWithIds: ["3"]
        )
        
        if #available(iOS 17, *) {
            
            await runSwiftTest(
                argument: argument,
                getObjectsType: .object(id: "3"),
                cachePolicy: .returnCacheDataAndFetch(requestPriority: .medium),
                expectedNumberOfChanges: 2,
                triggerSecondaryExternalDataFetchWithIds: ["3"]
            )
        }
    }
    
    // MARK: - Run Realm Test
    
    @MainActor private func runRealmTest(argument: TestArgument, getObjectsType: RepositorySyncGetObjectsType, cachePolicy: RepositorySyncCachePolicy, expectedNumberOfChanges: Int, triggerSecondaryExternalDataFetchWithIds: [String] = Array(), loggingEnabled: Bool = false) async {
        
        await runRealmTest(
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
    
    @MainActor private func runRealmTest(realmFileName: String, initialPersistedObjectsIds: [String], externalDataModelIds: [String], expectedCachedResponseDataModelIds: [String]?, expectedResponseDataModelIds: [String], getObjectsType: RepositorySyncGetObjectsType, cachePolicy: RepositorySyncCachePolicy, expectedNumberOfChanges: Int, triggerSecondaryExternalDataFetchWithIds: [String], loggingEnabled: Bool) async {
        
        if loggingEnabled {
            print("\n *** RUNNING REALM TEST *** \n")
        }
        let persistence = RealmRepositorySyncPersistenceTests.getPersistence(
            realmFileName: realmFileName,
            addObjectsByIds: initialPersistedObjectsIds
        )
        
        let externalDataFetch = Self.getExternalDataFetch(
            externalDataModelIds: externalDataModelIds
        )
        
        let repositorySync = RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch>(
            externalDataFetch: externalDataFetch,
            persistence: persistence
        )
        
        let triggersSecondaryExternalDataFetch: Bool = triggerSecondaryExternalDataFetchWithIds.count > 0
        
        var cancellables: Set<AnyCancellable> = Set()
        
        if triggersSecondaryExternalDataFetch {
                        
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.triggerSecondaryExternalDataFetchWithDelayForSeconds) {

                // TODO: See if I can trigger another external data fetch by fetching from mock external data and writing objects to the database. ~Levi
                
                if loggingEnabled {
                    print("\n PERFORMING SECONDARY EXTERNAL DATA FETCH")
                }
                
                let persistence = RealmRepositorySyncPersistenceTests.getPersistence(
                    realmFileName: realmFileName,
                    addObjectsByIds: []
                )
                
                let externalDataFetch = Self.getExternalDataFetch(
                    externalDataModelIds: triggerSecondaryExternalDataFetchWithIds
                )
                
                let additionalRepositorySync = RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch>(
                    externalDataFetch: externalDataFetch,
                    persistence: persistence
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
        
        RealmRepositorySyncPersistenceTests.deleteRealmDatabaseFile(fileName: realmFileName)
                
        if let expectedCachedResponseDataModelIds = expectedCachedResponseDataModelIds {
            
            let cachedResponseDataModelIds: [String] = MockRepositorySyncDataModel.sortDataModelIds(dataModels: cachedResponseRef?.objects ?? [])
                        
            if loggingEnabled {
                print("\n EXPECT")
                print("  CACHE RESPONSE: \(cachedResponseDataModelIds)")
                print("  TO EQUAL: \(expectedCachedResponseDataModelIds)")
            }
            
            #expect(cachedResponseDataModelIds == expectedCachedResponseDataModelIds)
        }
        
        let responseDataModelIds: [String] = MockRepositorySyncDataModel.sortDataModelIds(dataModels: responseRef?.objects ?? [])
        
        if loggingEnabled {
            print("\n EXPECT")
            print("  RESPONSE: \(responseDataModelIds)")
            print("  TO EQUAL: \(expectedResponseDataModelIds)")
        }
        
        #expect(responseDataModelIds == expectedResponseDataModelIds)
    }
    
    // MARK: - Run Swift Test
    
    @available(iOS 17, *)
    @MainActor private func runSwiftTest(argument: TestArgument, getObjectsType: RepositorySyncGetObjectsType, cachePolicy: RepositorySyncCachePolicy, expectedNumberOfChanges: Int, triggerSecondaryExternalDataFetchWithIds: [String] = Array(), loggingEnabled: Bool = false) async {
        
        await runSwiftTest(
            swiftDatabaseName: argument.swiftDatabaseName,
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
    
    @available(iOS 17, *)
    @MainActor private func runSwiftTest(swiftDatabaseName: String, initialPersistedObjectsIds: [String], externalDataModelIds: [String], expectedCachedResponseDataModelIds: [String]?, expectedResponseDataModelIds: [String], getObjectsType: RepositorySyncGetObjectsType, cachePolicy: RepositorySyncCachePolicy, expectedNumberOfChanges: Int, triggerSecondaryExternalDataFetchWithIds: [String], loggingEnabled: Bool) async {
        
        if loggingEnabled {
            print("\n *** RUNNING SWIFT TEST *** \n")
        }
        
        let persistence = SwiftRepositorySyncPersistenceTests.getPersistence(
            swiftDatabaseName: swiftDatabaseName,
            addObjectsByIds: initialPersistedObjectsIds
        )
        
        let externalDataFetch = Self.getExternalDataFetch(
            externalDataModelIds: externalDataModelIds
        )
        
        let repositorySync = RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch>(
            externalDataFetch: externalDataFetch,
            persistence: persistence
        )
        
        let triggersSecondaryExternalDataFetch: Bool = triggerSecondaryExternalDataFetchWithIds.count > 0
        
        var cancellables: Set<AnyCancellable> = Set()
        
        if triggersSecondaryExternalDataFetch {
                        
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.triggerSecondaryExternalDataFetchWithDelayForSeconds) {

                // TODO: See if I can trigger another external data fetch by fetching from mock external data and writing objects to the database. ~Levi
                
                if loggingEnabled {
                    print("\n PERFORMING SECONDARY EXTERNAL DATA FETCH")
                }
                
                let persistence = SwiftRepositorySyncPersistenceTests.getPersistence(
                    swiftDatabaseName: swiftDatabaseName,
                    addObjectsByIds: []
                )
                
                let externalDataFetch = Self.getExternalDataFetch(
                    externalDataModelIds: triggerSecondaryExternalDataFetchWithIds
                )
                
                let additionalRepositorySync = RepositorySync<MockRepositorySyncDataModel, MockRepositorySyncExternalDataFetch>(
                    externalDataFetch: externalDataFetch,
                    persistence: persistence
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
        
        SwiftRepositorySyncPersistenceTests.deleteSwiftDatabase(name: swiftDatabaseName)
                
        if let expectedCachedResponseDataModelIds = expectedCachedResponseDataModelIds {
            
            let cachedResponseDataModelIds: [String] = MockRepositorySyncDataModel.sortDataModelIds(dataModels: cachedResponseRef?.objects ?? [])
                        
            if loggingEnabled {
                print("\n EXPECT")
                print("  CACHE RESPONSE: \(cachedResponseDataModelIds)")
                print("  TO EQUAL: \(expectedCachedResponseDataModelIds)")
            }
            
            #expect(cachedResponseDataModelIds == expectedCachedResponseDataModelIds)
        }
        
        let responseDataModelIds: [String] = MockRepositorySyncDataModel.sortDataModelIds(dataModels: responseRef?.objects ?? [])
        
        if loggingEnabled {
            print("\n EXPECT")
            print("  RESPONSE: \(responseDataModelIds)")
            print("  TO EQUAL: \(expectedResponseDataModelIds)")
        }
        
        #expect(responseDataModelIds == expectedResponseDataModelIds)
    }
}

// MARK: - Get External Data Fetch

extension RepositorySyncTests {
    
    private static func getExternalDataFetch(externalDataModelIds: [String]) -> MockRepositorySyncExternalDataFetch {
        
        let externalDataFetch = MockRepositorySyncExternalDataFetch(
            objects: MockRepositorySyncDataModel.getDataModelsFromIds(ids: externalDataModelIds),
            delayRequestSeconds: Self.mockExternalDataFetchDelayRequestForSeconds
        )
        
        return externalDataFetch
    }
}
