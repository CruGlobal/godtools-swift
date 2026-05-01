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
    
    private let localActivityCounterCache: LocalActivityCounterCache
    private let cache: UserCountersCache
    
    init(localActivityCounterCache: LocalActivityCounterCache, cache: UserCountersCache) {
        
        self.localActivityCounterCache = localActivityCounterCache
        self.cache = cache
    }
    
    private var persistence: any Persistence<UserCounterDataModel, UserCounterCodable> {
        return cache.persistence
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
        return persistence
            .observeCollectionChangesPublisher()
    }
    
    func getCachedCounter(id: String) throws -> UserCounterDataModel? {
        return try cache.getCounter(id: id)
    }
    
    func getCachedCountersPublisher() -> AnyPublisher<[UserCounterDataModel], Error> {
        
        return AnyPublisher() {
            return try await self.cache.mergeLocalCountersWithCachedCounters()
        }
    }
    
    func incrementCounterPublisher(id: String) -> AnyPublisher<LocalActivityCountDataModel, Error> {
        
        do {
            
            let counter = try localActivityCounterCache.incrementCounter(id: id)
                        
            return Just(counter)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        catch let error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func deleteCachedCounters() throws {
                        
        try cache.deleteCounters()
    }
}
