//
//  UserCountersSync.swift
//  godtools
//
//  Created by Levi Eggert on 4/30/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

final class UserCountersSync {
    
    private let api: UserCountersApiInterface
    private let cache: UserCountersCache
    private let localActivityCounterCache: LocalActivityCounterCache
    private let syncInvalidator: SyncInvalidator
    
    private(set) var isSyncing: Bool = false
    
    init(api: UserCountersApiInterface, cache: UserCountersCache, localActivityCounterCache: LocalActivityCounterCache, syncInvalidator: SyncInvalidator) {
        
        self.api = api
        self.cache = cache
        self.localActivityCounterCache = localActivityCounterCache
        self.syncInvalidator = syncInvalidator
    }
    
    func sync(requestPriority: RequestPriority, forceSync: Bool = false) -> AnyPublisher<Void, Error> {
        return AnyPublisher() {
            return try await self.sync(requestPriority: requestPriority, forceSync: forceSync)
        }
    }
    
    func sync(requestPriority: RequestPriority, forceSync: Bool = false) async throws {
        
        let shouldSync: Bool = syncInvalidator.shouldSync || forceSync
        
        guard !isSyncing && shouldSync else {
            return
        }
        
        isSyncing = true
        
        do {
            
            _ = try await pushLocalActivityCountersToRemote(requestPriority: requestPriority)
            
            let remoteCounters: [UserCounterCodable] = try await api.fetchUserCounters(requestPriority: requestPriority)
            
            _ = try await cache.persistence.writeObjectsAsync(
                externalObjects: remoteCounters,
                writeOption: .deleteObjectsNotInExternal,
                getOption: nil
            )
            
            syncInvalidator.didSync()
            
            isSyncing = false
        }
        catch let error {
            
            isSyncing = false
            
            print(error)
            
            throw error
        }
    }
    
    private func pushLocalActivityCountersToRemote(requestPriority: RequestPriority) async throws -> [UserCounterCodable] {
        
        let localActivityCounters: [LocalActivityCountDataModel] = try await localActivityCounterCache.persistence.getDataModelsAsync(getOption: .allObjects)
        
        var updatedCounters: [UserCounterCodable] = Array()
        
        for localCounter in localActivityCounters {
            
            let updatedCounter: UserCounterCodable? = try await pushLocalCounterToRemote(
                counter: localCounter,
                requestPriority: requestPriority
            )
            
            if let updatedCounter = updatedCounter {
                updatedCounters.append(updatedCounter)
            }
        }
        
        return updatedCounters
    }
    
    private func pushLocalCounterToRemote(counter: LocalActivityCountDataModel, requestPriority: RequestPriority) async throws -> UserCounterCodable? {
        
        guard counter.count > 0 else {
            return nil
        }
        
        let counterId: String = counter.id
        let count: Int = counter.count
        
        let remoteCounter: UserCounterCodable = try await api.incrementUserCounter(
            id: counterId,
            increment: count,
            requestPriority: requestPriority
        )
        
        try localActivityCounterCache
            .decrementCount(id: counterId, decrementBy: count)
        
        return remoteCounter
    }
}
