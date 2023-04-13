//
//  RemoteUserCountersSync.swift
//  godtools
//
//  Created by Rachael Skeath on 1/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class RemoteUserCountersSync {
    
    private let api: UserCountersAPIType
    private let cache: RealmUserCountersCache
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(api: UserCountersAPIType, cache: RealmUserCountersCache) {
        
        self.api = api
        self.cache = cache
    }
    
    func syncUpdatedUserCountersWithRemote() {
        
        if cancellables.isEmpty == false {
            for cancellable in cancellables {
                cancellable.cancel()
            }
            
            cancellables.removeAll()
        }
        
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
