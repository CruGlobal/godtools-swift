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
    
    private let api: any UserCountersApiInterface
    private let cache: UserCountersCache
        
    init(api: any UserCountersApiInterface, cache: UserCountersCache) {
        
        self.api = api
        self.cache = cache
    }
    
    func syncUpdatedUserCountersWithRemote(requestPriority: RequestPriority) async throws {
        
        let cache: UserCountersCache = self.cache
        let userCountersToSync: [UserCounterDataModel] = try await cache.getUserCountersWithIncrementGreaterThanZero()
        
        for userCounter in userCountersToSync {
            
            let incrementValue: Int = userCounter.incrementValue
            
            let updatedUserCounter: UserCounterDecodable = try await api.incrementUserCounter(
                id: userCounter.id,
                increment: incrementValue,
                requestPriority: requestPriority
            )
            
            _ = try cache.syncUserCounter(
                userCounter: updatedUserCounter,
                incrementValueBeforeRemoteUpdate: incrementValue
            )
        }
    }
    
    @MainActor func syncUpdatedUserCountersWithRemotePublisher(requestPriority: RequestPriority) -> AnyPublisher<Void, Error> {
        
        return Future { promise in
            Task {
                do {
                    try await self.syncUpdatedUserCountersWithRemote(requestPriority: requestPriority)
                    return promise(.success(Void()))
                }
                catch let error {
                    return promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
