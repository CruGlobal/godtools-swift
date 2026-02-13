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

class UserCountersRepository: RepositorySync<UserCounterDataModel, UserCountersAPI> {
    
    private let api: UserCountersAPI
    private let cache: UserCountersCache
    
    let remoteUserCountersSync: RemoteUserCountersSync
    
    private var fetchRemoteCountersTask: Task<Void, Error>?
    
    init(externalDataFetch: UserCountersAPI, persistence: any Persistence<UserCounterDataModel, UserCounterDecodable>, cache: UserCountersCache, remoteUserCountersSync: RemoteUserCountersSync) {
        
        self.api = externalDataFetch
        self.cache = cache
        self.remoteUserCountersSync = remoteUserCountersSync
        
        super.init(externalDataFetch: externalDataFetch, persistence: persistence)
    }
}

extension UserCountersRepository {
    
    func getUserCounter(id: String) throws -> UserCounterDataModel? {
        
        return try persistence.getDataModel(id: id)
    }
    
    @MainActor func getUserCountersChanged(reloadFromRemote: Bool, requestPriority: RequestPriority) -> AnyPublisher<Void, Error> {
        
        if reloadFromRemote {
            
            fetchRemoteCountersTask?.cancel()
            
            fetchRemoteCountersTask = Task {
                _ = try await fetchRemoteUserCounters(requestPriority: requestPriority)
            }
        }
        
        return persistence
            .observeCollectionChangesPublisher()
    }
    
    func getUserCounters() async throws -> [UserCounterDataModel] {
        
        return try await cache.getAllUserCounters()
    }
    
    func fetchRemoteUserCounters(requestPriority: RequestPriority) async throws -> [UserCounterDataModel] {
        
        let userCounters: [UserCounterDecodable] = try await api.fetchUserCounters(
            requestPriority: requestPriority
        )
        
        return try cache.syncUserCounters(
            userCounters: userCounters
        )
    }
    
    func incrementCachedUserCounterBy1(id: String) throws -> [UserCounterDataModel] {
        
        return try cache.incrementUserCounterBy1(id: id)
    }
    
    func deleteUserCounters() throws {
        
        return try cache.deleteAllUserCounters()
    }
    
    func syncUpdatedUserCountersWithRemote(requestPriority: RequestPriority) async throws {
        
        try await remoteUserCountersSync.syncUpdatedUserCountersWithRemote(
            requestPriority: requestPriority
        )
    }
}
