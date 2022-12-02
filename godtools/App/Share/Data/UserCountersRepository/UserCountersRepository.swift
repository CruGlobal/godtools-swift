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
    
    func fetchRemoteUserCounters() -> AnyPublisher<[RealmUserCounter], URLResponseError> {
        
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
    
    func incrementUserCounter(_ userCounter: UserCounterDataModel) -> AnyPublisher<RealmUserCounter, URLResponseError> {
        
        let incrementValueBeforeSyncAttempt = userCounter.incrementValue
        
        return api.incrementCounterPublisher(userCounter)
            .flatMap { updatedUserCounterFromRemote in
                
                return self.userCounterPublisher(value: updatedUserCounterFromRemote, remoteSyncSuccess: true)
            }
            .catch { _ in
                
                return self.userCounterPublisher(value: userCounter, remoteSyncSuccess: false)
            }
            .flatMap { userCounter, remoteSyncSuccess in
                
                return self.syncUserCounter(userCounter, remoteSyncSuccess: remoteSyncSuccess, incrementValueBeforeSyncAttempt: incrementValueBeforeSyncAttempt)
            }
            .eraseToAnyPublisher()
    }
    
    private func userCounterPublisher(value: UserCounterDataModel, remoteSyncSuccess: Bool) -> AnyPublisher<(userCounter: UserCounterDataModel, remoteSyncSuccess: Bool), URLResponseError> {
        
        return Just((value, remoteSyncSuccess))
            .setFailureType(to: URLResponseError.self)
            .eraseToAnyPublisher()
    }
    
    private func syncUserCounter(_ userCounter: UserCounterDataModel, remoteSyncSuccess: Bool, incrementValueBeforeSyncAttempt: Int) -> AnyPublisher<RealmUserCounter, URLResponseError>  {
        
        let incrementValueBeforeSuccessfulRemoteUpdate = remoteSyncSuccess ? incrementValueBeforeSyncAttempt : nil
        
        return cache.syncUserCounter(userCounter, incrementValueBeforeSuccessfulRemoteUpdate: incrementValueBeforeSuccessfulRemoteUpdate)
            .mapError { error in
                return URLResponseError.otherError(error: error)
            }
            .eraseToAnyPublisher()
    }
}
