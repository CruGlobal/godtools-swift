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
    
    private let getUserActivityBadgeUseCase: GetUserActivityBadgeUseCase
    private let userCounterRepository: UserCountersRepository
    
    init(getUserActivityBadgeUseCase: GetUserActivityBadgeUseCase, userCounterRepository: UserCountersRepository) {
        
        self.getUserActivityBadgeUseCase = getUserActivityBadgeUseCase
        self.userCounterRepository = userCounterRepository
    }
    
    func getUserActivityPublisher() -> AnyPublisher<UserActivityDomainModel, Never> {
        
        return userCounterRepository.getUserCountersChanged(reloadFromRemote: true)
            .flatMap { _ in
                
                let allUserCounters = self.userCounterRepository.getUserCounters().map { UserCounterDomainModel(dataModel: $0) }
                
                let userActivityDomainModel = self.getUserActivityDomainModel(from: allUserCounters)
                
                return Just(userActivityDomainModel)
                
            }
            .eraseToAnyPublisher()
    }
    
    private func getUserActivityDomainModel(from counters: [UserCounterDomainModel]) -> UserActivityDomainModel {
        
        let userCounterDictionary = buildDictionary(from: counters)
        
        let userActivity = UserActivity(counters: userCounterDictionary)
        let badges = userActivity.badges.map { self.getUserActivityBadgeUseCase.getBadge(from: $0) }
        
        return UserActivityDomainModel(badges: badges)
    }
    
    private func buildDictionary(from counters: [UserCounterDomainModel]) -> [String: KotlinInt] {
        
        var dict = [String: KotlinInt]()
        
        for counter in counters {
            
            dict[counter.id] = KotlinInt(int: Int32(counter.count))
        }
        
        return dict
    }
}
