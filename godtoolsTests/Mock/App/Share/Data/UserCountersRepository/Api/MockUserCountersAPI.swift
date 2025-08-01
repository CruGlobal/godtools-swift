//
//  UserCountersAPIMock.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 4/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation
@testable import godtools

class UserCountersAPIMock {
    
    private var fetchedCounters: [UserCounterDecodable] = [UserCounterDecodable]()
    private var remoteCountValues: [Int] = [Int]()
    
    func setMockFetchResponse(fetchedCounters: [UserCounterDecodable]) {
        self.fetchedCounters = fetchedCounters
    }
    
    func setMockRemoteCountResponse(countValues: [Int]) {
        self.remoteCountValues = countValues
    }
}
    
extension UserCountersAPIMock: UserCountersApiInterface {
    
    func fetchUserCountersPublisher(requestPriority: RequestPriority) -> AnyPublisher<[UserCounterDecodable], Error> {
        
        return Just(fetchedCounters)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func incrementUserCounterPublisher(id: String, increment: Int, requestPriority: RequestPriority) -> AnyPublisher<UserCounterDecodable, Error> {
        
        let remoteCount = remoteCountValues.removeFirst()
        let userCounterDecodable = UserCounterDecodable(id: id, count: increment + remoteCount)
        
        return Just(userCounterDecodable)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
}
