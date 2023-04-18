//
//  UserCountersAPIMock.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 4/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
@testable import godtools

class UserCountersAPIMock {
    
    private var fetchedCounters: [UserCounterDecodable] = [UserCounterDecodable]()
    private var remoteCount: Int = 5
    
    func setMockFetchResponse(fetchedCounters: [UserCounterDecodable]) {
        self.fetchedCounters = fetchedCounters
    }
    
    func setMockRemoteCountResponse(count: Int) {
        self.remoteCount = count
    }
}
    
extension UserCountersAPIMock: UserCountersAPIType {
    
    func fetchUserCountersPublisher() -> AnyPublisher<[UserCounterDecodable], URLResponseError> {
        
        return Just(fetchedCounters)
            .setFailureType(to: URLResponseError.self)
            .eraseToAnyPublisher()
    }
    
    func incrementUserCounterPublisher(id: String, increment: Int) -> AnyPublisher<UserCounterDecodable, URLResponseError> {
        
        let userCounterDecodable = UserCounterDecodable(id: id, count: increment + remoteCount)
        
        return Just(userCounterDecodable)
            .setFailureType(to: URLResponseError.self)
            .eraseToAnyPublisher()
    }
    
}
