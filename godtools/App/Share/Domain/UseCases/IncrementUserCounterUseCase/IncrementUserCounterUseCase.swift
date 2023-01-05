//
//  IncrementUserCounterUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 1/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class IncrementUserCounterUseCase {
    
    enum UserCounterInteraction {
        case sessionLaunch
    }
    
    private let userCountersRepository: UserCountersRepository
    
    init(userCountersRepository: UserCountersRepository) {
        self.userCountersRepository = userCountersRepository
    }
    
    func incrementUserCounter(for interaction: UserCounterInteraction) {
        
        let userCounterId: String
        let userCounterNames = UserCounterNames.shared
        switch interaction {
            
        case .sessionLaunch:
            userCounterId = userCounterNames.SESSION
            
        }
        
        userCountersRepository.incrementCachedUserCounterBy1(id: userCounterId)
    }
    
}
