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
    
    init(api: UserCountersAPI) {
        self.api = api
    }
    
    func fetchRemoteUserCounters() -> AnyPublisher<Data, URLResponseError> {
        
        return api.fetchUserCountersPublisher()
    }
    
    func incrementUserCounter(id: Int, value: Int) -> AnyPublisher<Data, URLResponseError> {
        
        return api.incrementCounterPublisher(counterId: id, incrementValue: value)
    }
}
