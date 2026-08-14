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

final class UserCountersRepository: Sendable {
    
    private let localActivityCounterCache: LocalActivityCounterCache
    private let cache: UserCountersCache
    
    init(localActivityCounterCache: LocalActivityCounterCache, cache: UserCountersCache) {
        
        self.localActivityCounterCache = localActivityCounterCache
        self.cache = cache
    }
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
        return cache
            .persistence
            .observeCollectionChangesPublisher()
    }
    
    func getCachedCounter(id: String) throws -> UserCounterDataModel? {
        return try cache.getCounter(id: id)
    }
    
    func getCachedCounters() async throws -> [UserCounterDataModel] {
        
        return try await self.cache.mergeLocalCountersWithCachedCounters()
    }
    
    func incrementCounter(id: String) async throws -> LocalActivityCountDataModel {
        
        return try await self.localActivityCounterCache.incrementCounter(id: id)
    }
    
    func deleteCounters() async throws {
                        
        try await cache.deleteCounters()
    }
}
