//
//  UserCountersRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 11/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation
import RepositorySync

final class UserCountersRepository {
    
    private let api: UserCountersApiInterface
    private let localUserCounterIncrement: LocalUserCounterIncrement
    private let cache: UserCountersCache
    private let syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    let persistence: any Persistence<UserCounterDataModel, UserCounterCodable>
    
    init(api: UserCountersApiInterface, persistence: any Persistence<UserCounterDataModel, UserCounterCodable>, localUserCounterIncrement: LocalUserCounterIncrement, cache: UserCountersCache, syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface) {
        
        self.api = api
        self.persistence = persistence
        self.localUserCounterIncrement = localUserCounterIncrement
        self.cache = cache
        self.syncInvalidatorPersistence = syncInvalidatorPersistence
    }
    
    func getCachedCounter(id: String) throws -> UserCounterDataModel? {
        
        guard let counter = try persistence.getDataModel(id: id) else {
            return nil
        }
        
        let count: Int = counter.count
        let localCount: Int = try localUserCounterIncrement.getCounter(id: id)?.localCount ?? 0
        
        return UserCounterDataModel(
            id: id,
            count: count + localCount
        )
    }
    
    func getCachedCountersPublisher() -> AnyPublisher<[UserCounterDataModel], Error> {
        
        return AnyPublisher() {
            return try await self.mergeLocalCountersWithCachedCounters()
        }
    }
    
    func deleteCachedCounters() throws {
                
        getCountersSyncInvalidator().resetSync()
        
        try cache.deleteCounters()
    }
    
    private func getCountersSyncInvalidator() -> SyncInvalidator {
        
        return SyncInvalidator(
            id:  "userCounters.getCounters",
            timeInterval: .hours(hour: 2),
            persistence: syncInvalidatorPersistence
        )
    }
}

// MARK: - Increment Local Counter

extension UserCountersRepository {
    
    func incrementCounterPublisher(id: String) -> AnyPublisher<LocalUserCounter, Error> {
        
        do {
            
            let localUserCounter: LocalUserCounter = try localUserCounterIncrement.incrementCounter(id: id)
            
            return Just(localUserCounter)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        catch let error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - Sync Local Counters

extension UserCountersRepository {
    
    private func pushLocalCountersToRemote(requestPriority: RequestPriority) async throws -> [UserCounterCodable] {
        
        let localCounters: [LocalUserCounter] = try localUserCounterIncrement.getCounters()
        
        var updatedCounters: [UserCounterCodable] = Array()
        
        for localCounter in localCounters {
            
            let updatedCounter: UserCounterCodable? = try await pushLocalCounterToRemote(
                localCounter: localCounter,
                requestPriority: requestPriority
            )
            
            if let updatedCounter = updatedCounter {
                updatedCounters.append(updatedCounter)
            }
        }
        
        return updatedCounters
    }
    
    private func pushLocalCounterToRemote(localCounter: LocalUserCounter, requestPriority: RequestPriority) async throws -> UserCounterCodable? {
        
        guard localCounter.localCount > 0 else {
            return nil
        }
        
        let counterId: String = localCounter.id
        let localCount: Int = localCounter.localCount
        
        let remoteCounter: UserCounterCodable = try await api.incrementUserCounter(
            id: counterId,
            increment: localCount,
            requestPriority: requestPriority
        )
        
        try localUserCounterIncrement
            .decrementCount(id: counterId, decrementBy: localCount)
        
        return remoteCounter
    }
}

// MARK: - Get Counters

extension UserCountersRepository {
    
    func getCountersPublisher(requestPriority: RequestPriority) -> AnyPublisher<[UserCounterDataModel], Error> {
        
        return AnyPublisher() {
            
            return try await self.getCounters(
                requestPriority: requestPriority
            )
        }
    }
    
    private func getCounters(requestPriority: RequestPriority) async throws -> [UserCounterDataModel] {
                      
        let syncInvalidator: SyncInvalidator = getCountersSyncInvalidator()
        
        guard syncInvalidator.shouldSync else {
            return try await mergeLocalCountersWithCachedCounters()
        }
        
        _ = try await pushLocalCountersToRemote(requestPriority: requestPriority)
                        
        let remoteCounters: [UserCounterCodable] = try await api.fetchUserCounters(requestPriority: requestPriority)
                    
        try cache.writeCounters(counters: remoteCounters)
        
        syncInvalidator.didSync()
        
        let counters: [UserCounterDataModel] = remoteCounters.map {
            $0.toModel()
        }
                
        return try mergeLocalCountersWithCounters(counters: counters)
    }
    
    private func mergeLocalCountersWithCachedCounters() async throws -> [UserCounterDataModel] {
        
        let cachedCounters: [UserCounterDataModel] = try await persistence.getDataModelsAsync(getOption: .allObjects)
        
        return try mergeLocalCountersWithCounters(counters: cachedCounters)
    }
    
    private func mergeLocalCountersWithCounters(counters: [UserCounterDataModel]) throws -> [UserCounterDataModel] {
        
        return try counters.map { (counter: UserCounterDataModel) in
            
            let localCounter: LocalUserCounter? = try localUserCounterIncrement.getCounter(id: counter.id)
            
            let localCount: Int = localCounter?.localCount ?? 0
                        
            return UserCounterDataModel(
                id: counter.id,
                count: counter.count + localCount
            )
        }
    }
}
