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
    
    init(api: UserCountersAPI, cache: RealmUserCountersCache) {
        self.api = api
        self.cache = cache
    }
    
    func fetchRemoteUserCounters() -> AnyPublisher<[UserCounterDataModel], URLResponseError> {
        
        return api.fetchUserCountersPublisher()
            .flatMap { userCountersResponse in
                
                return self.cache.syncUserCounters(userCountersResponse.userCounters)
                    .mapError { error in
                        return URLResponseError.otherError(error: error)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func incrementUserCounter(id: Int, value: Int) -> AnyPublisher<UserCounterDataModel, URLResponseError> {
        
        return api.incrementCounterPublisher(counterId: id, incrementValue: value)
            .flatMap { incrementUserCounterResponse in
                
                return self.cache.syncUserCounter(incrementUserCounterResponse.userCounter)
                    .mapError { error in
                        return URLResponseError.otherError(error: error)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
