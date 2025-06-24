//
//  RemoteUserCountersSync.swift
//  godtools
//
//  Created by Rachael Skeath on 1/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

class RemoteUserCountersSync {
    
    private let api: UserCountersAPIType
    private let cache: RealmUserCountersCache
        
    init(api: UserCountersAPIType, cache: RealmUserCountersCache) {
        
        self.api = api
        self.cache = cache
    }
    
    func syncUpdatedUserCountersWithRemotePublisher(requestPriority: RequestPriority) -> AnyPublisher<Void, Error> {
        
        let cache: RealmUserCountersCache = self.cache
        let userCountersToSync: [UserCounterDataModel] = cache.getUserCountersWithIncrementGreaterThanZero()
        
        let publishers: [AnyPublisher<Void, Error>] = userCountersToSync.map { (userCounter: UserCounterDataModel) in
           
            let incrementValue: Int = userCounter.incrementValue
            
            return api.incrementUserCounterPublisher(
                id: userCounter.id,
                increment: incrementValue,
                requestPriority: requestPriority
            )
            .flatMap { (userCounterUpdatedFromRemote: UserCounterDecodable) in
                
                cache.syncUserCounter(
                    userCounterUpdatedFromRemote,
                    incrementValueBeforeRemoteUpdate: incrementValue
                )
                .map { _ in
                    return Void()
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .map { _ in
                Void()
            }
            .eraseToAnyPublisher()
    }
}
