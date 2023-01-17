//
//  GetUserActivityUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsToolParser

class GetUserActivityUseCase {
    
    private let userCounterRepository: UserCountersRepository
    
    init(userCounterRepository: UserCountersRepository) {
        
        self.userCounterRepository = userCounterRepository
    }
    
    func getUserActivityPublisher() -> AnyPublisher<UserActivity, Never> {
        
        return userCounterRepository.getUserCountersChanged(reloadFromRemote: true)
            .flatMap { _ in
                
                let allUserCounters = self.userCounterRepository.getUserCounters()
                let userCounterDictionary = self.buildDictionary(from: allUserCounters)
                
                let userActivity = UserActivity(counters: userCounterDictionary)
                
                return Just(userActivity)
                
            }
            .eraseToAnyPublisher()
    }
    
    private func buildDictionary(from counters: [UserCounterDataModel]) -> [String: KotlinInt] {
        
        var dict = [String: KotlinInt]()
        
        for counter in counters {
            
            let count = counter.incrementValue + counter.latestCountFromAPI
            dict[counter.id] = KotlinInt(int: Int32(count))
        }
        
        return dict
    }
}
