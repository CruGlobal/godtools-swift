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
    
    var fetchedCounters: [UserCounterDecodable] = [
        UserCounterDecodable(id: "counter_1", count: 1),
        UserCounterDecodable(id: "counter_2", count: 2),
        UserCounterDecodable(id: "counter_3", count: 3)
    ]
    
    func setMockFetchedCounters() {
        
        
    }
}
    
extension UserCountersAPIMock: UserCountersAPIType {
    
    func fetchUserCountersPublisher() -> AnyPublisher<[UserCounterDecodable], URLResponseError> {
        
        return Just(fetchedCounters)
            .setFailureType(to: URLResponseError.self)
            .eraseToAnyPublisher()
    }
    
    func incrementUserCounterPublisher(id: String, increment: Int) -> AnyPublisher<UserCounterDecodable, URLResponseError> {
        
        let userCounterDecodable = UserCounterDecodable(id: id, count: 5)
        
        return Just(userCounterDecodable)
            .setFailureType(to: URLResponseError.self)
            .eraseToAnyPublisher()
    }
    
}
