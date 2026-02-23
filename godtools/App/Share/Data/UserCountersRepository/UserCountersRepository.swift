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

class UserCountersRepository {
    
    private let api: UserCountersAPI
    private let cache: RealmUserCountersCache
    private let remoteUserCountersSync: RemoteUserCountersSync
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(api: UserCountersAPI, cache: RealmUserCountersCache, remoteUserCountersSync: RemoteUserCountersSync) {
        self.api = api
        self.cache = cache
        self.remoteUserCountersSync = remoteUserCountersSync
    }
    
    func getUserCounter(id: String) -> UserCounterDomainModel? {
        
        guard let userCounterDataModel = cache.getUserCounter(id: id) else {
            return nil
        }
        
        return UserCounterDomainModel(dataModel: userCounterDataModel)
    }
    
    @MainActor func getUserCountersChangedPublisher(reloadFromRemote: Bool, requestPriority: RequestPriority) -> AnyPublisher<Void, Never> {
        
        if reloadFromRemote {
            
            fetchRemoteUserCountersPublisher(requestPriority: requestPriority)
                .sink(receiveCompletion: { _ in
                }, receiveValue: { _ in
                    
                })
                .store(in: &cancellables)
        }
        
        return cache.getUserCountersChanged()
    }
    
    func getUserCounters() -> [UserCounterDataModel] {
        
        return cache.getAllUserCounters()
    }
    
    func fetchRemoteUserCountersPublisher(requestPriority: RequestPriority) -> AnyPublisher<[UserCounterDataModel], Error> {
        
        // TODO: Eventually remove AnyPublisher() and support async await. ~Levi
        
        return AnyPublisher() {
            return try await self.api.fetchUserCounters(requestPriority: requestPriority)
        }
        .flatMap { (userCounters: [UserCounterDecodable]) in
            
            return self.cache.syncUserCounters(userCounters)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    func incrementCachedUserCounterBy1Publisher(id: String) -> AnyPublisher<[UserCounterDataModel], Error> {
        
        return cache.incrementUserCounterBy1(id: id)
    }
    
    func deleteUserCountersPublisher() -> AnyPublisher<Void, Error> {
        
        return cache.deleteAllUserCounters()
    }
    
    func syncUpdatedUserCountersWithRemotePublisher(requestPriority: RequestPriority) -> AnyPublisher<Void, Error> {
        return remoteUserCountersSync.syncUpdatedUserCountersWithRemotePublisher(
            requestPriority: requestPriority
        )
        .eraseToAnyPublisher()
    }
}
