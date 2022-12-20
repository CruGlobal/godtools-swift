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
    
    func incrementUserCounter(id: String, increment: Int) -> AnyPublisher<RealmUserCounter, URLResponseError> {
        
        let incrementValueBeforeSyncAttempt = increment
        
        return api.incrementCounterPublisher(id: id, increment: increment)
            .flatMap { updatedUserCounterFromRemote in
                
                return self.userCounterDecodablePublisher(value: updatedUserCounterFromRemote, remoteSyncSuccess: true)
            }
            .catch { _ in
                
                let incrementCounterAfterSyncFail = UserCounterDecodable(id: id, count: increment)
                return self.userCounterDecodablePublisher(value: incrementCounterAfterSyncFail, remoteSyncSuccess: false)
            }
            .flatMap { userCounter, remoteSyncSuccess in
                
                return self.syncUserCounter(userCounter, remoteSyncSuccess: remoteSyncSuccess, incrementValueBeforeSyncAttempt: incrementValueBeforeSyncAttempt)
            }
            .eraseToAnyPublisher()
    }
    
    private func userCounterDecodablePublisher(value: UserCounterDecodable, remoteSyncSuccess: Bool) -> AnyPublisher<(userCounter: UserCounterDecodable, remoteSyncSuccess: Bool), URLResponseError> {
        
        return Just((value, remoteSyncSuccess))
            .setFailureType(to: URLResponseError.self)
            .eraseToAnyPublisher()
    }
    
    private func syncUserCounter(_ userCounter: UserCounterDecodable, remoteSyncSuccess: Bool, incrementValueBeforeSyncAttempt: Int) -> AnyPublisher<RealmUserCounter, URLResponseError>  {
        
        let incrementValueBeforeSuccessfulRemoteUpdate = remoteSyncSuccess ? incrementValueBeforeSyncAttempt : nil
        
        return cache.syncUserCounter(userCounter, incrementValueBeforeSuccessfulRemoteUpdate: incrementValueBeforeSuccessfulRemoteUpdate)
            .mapError { error in
                return URLResponseError.otherError(error: error)
            }
            .eraseToAnyPublisher()
    }
}
