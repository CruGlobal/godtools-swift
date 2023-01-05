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
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(api: UserCountersAPI, cache: RealmUserCountersCache) {
        self.api = api
        self.cache = cache
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
    
    func incrementCachedUserCounterBy1(id: String) {
        
        cache.incrementUserCounterBy1(id: id)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { _ in
                
            })
            .store(in: &cancellables)

    }
    
    func syncUpdatedUserCountersWithRemote() {
        
        let userCountersToSync = cache.getUserCountersWithIncrementGreaterThanZero()
        
        for userCounter in userCountersToSync {
            
            let incrementValue = userCounter.incrementValue
            
            api.incrementUserCounterPublisher(id: userCounter.id, increment: incrementValue)
                .flatMap { userCounterUpdatedFromRemote in
                    
                    return self.cache.syncUserCounter(userCounterUpdatedFromRemote, incrementValueBeforeRemoteUpdate: incrementValue)
                        .mapError { error in
                            return URLResponseError.otherError(error: error)
                        }
                        .eraseToAnyPublisher()
                }
                .sink(receiveCompletion: { _ in
                                        
                }, receiveValue: { _ in
                    
                })
                .store(in: &cancellables)
        }
    }
}
