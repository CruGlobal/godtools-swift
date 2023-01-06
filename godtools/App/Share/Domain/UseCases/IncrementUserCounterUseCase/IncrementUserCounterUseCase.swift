//
//  IncrementUserCounterUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import GodToolsToolParser

class IncrementUserCounterUseCase {
    
    enum UserCounterInteraction {
        case sessionLaunch
        case linkShared
        case imageShared
    }
    
    private let userCountersRepository: UserCountersRepository
    
    init(userCountersRepository: UserCountersRepository) {
        self.userCountersRepository = userCountersRepository
    }
    
    func incrementUserCounter(for interaction: UserCounterInteraction) -> AnyPublisher<UserCounterDomainModel, Error> {
        
        let userCounterId = getUserCounterId(for: interaction)
        
        return userCountersRepository.incrementCachedUserCounterBy1(id: userCounterId)
            .flatMap { userCounterDataModel in
                
                let userCounterDomainModel = UserCounterDomainModel(dataModel: userCounterDataModel)
                
                return Just(userCounterDomainModel)
            }
            .eraseToAnyPublisher()
    }
    
    private func getUserCounterId(for interaction: UserCounterInteraction) -> String {
        
        let userCounterNames = UserCounterNames.shared
        let userCounterId: String
        
        switch interaction {
            
        case .sessionLaunch:
            userCounterId = userCounterNames.SESSION
            
        case .linkShared:
            userCounterId = userCounterNames.LINK_SHARED
            
        case .imageShared:
            userCounterId = userCounterNames.IMAGE_SHARED
        }
        
        return userCounterId
    }
    
}
