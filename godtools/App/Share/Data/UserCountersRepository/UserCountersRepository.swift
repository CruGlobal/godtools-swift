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

class UserCountersRepository {
    
    private let api: UserCountersApi
    private let localUserCounterIncrement: LocalUserCounterIncrement
    private let cache: UserCountersCache
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    let persistence: any Persistence<UserCounterDataModel, UserCounterCodable>
    
    init(api: UserCountersApi, persistence: any Persistence<UserCounterDataModel, UserCounterCodable>, localUserCounterIncrement: LocalUserCounterIncrement, cache: UserCountersCache) {
        
        self.api = api
        self.persistence = persistence
        self.localUserCounterIncrement = localUserCounterIncrement
        self.cache = cache
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
            return try await self.persistence.getDataModelsAsync(getOption: .allObjects)
        }
    }
    
    func deleteCachedCounters() throws {
                
        try cache.deleteCounters()
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
                        
        _ = try await pushLocalCountersToRemote(requestPriority: requestPriority)
                        
        let remoteCounters: [UserCounterCodable] = try await api.fetchUserCounters(requestPriority: requestPriority)
                    
        let counters: [UserCounterDataModel] = try await persistence
            .writeObjectsAsync(
                externalObjects: remoteCounters,
                writeOption: nil,
                getOption: .allObjects
            )
                
        return try mergeLocalCountersWithRemoteCounters(remoteCounters: counters)
    }
    
    private func mergeLocalCountersWithRemoteCounters(remoteCounters: [UserCounterDataModel]) throws -> [UserCounterDataModel] {
        
        return try remoteCounters.map { (remoteCounter: UserCounterDataModel) in
            
            let localCounter: LocalUserCounter? = try localUserCounterIncrement.getCounter(id: remoteCounter.id)
            
            let localCount: Int = localCounter?.localCount ?? 0
                        
            return UserCounterDataModel(
                id: remoteCounter.id,
                count: remoteCounter.count + localCount
            )
        }
    }
}
