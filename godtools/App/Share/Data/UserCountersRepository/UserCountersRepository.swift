//
//  UserCountersRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 11/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

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
        
        guard let userCounterDataModel = cache.getUserCounter(id: id) else { return nil }
        
        return UserCounterDomainModel(dataModel: userCounterDataModel)
    }
    
    func getUserCountersChanged(reloadFromRemote: Bool) -> AnyPublisher<Void, Never> {
            
            if reloadFromRemote {
                
                fetchRemoteUserCounters()
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
    
    func fetchRemoteUserCounters() -> AnyPublisher<[UserCounterDataModel], URLResponseError> {
        
        return api.fetchUserCountersPublisher()
            .flatMap { userCounters in
                
                return self.cache.syncUserCounters(userCounters)
                    .mapError { error in
                        return URLResponseError.otherError(error: error)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func incrementCachedUserCounterBy1(id: String) -> AnyPublisher<UserCounterDataModel, Error> {
        
        return cache.incrementUserCounterBy1(id: id)
    }
    
    func syncUpdatedUserCountersWithRemote() {
        
        remoteUserCountersSync.syncUpdatedUserCountersWithRemote()
    }
}
