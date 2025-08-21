//
//  TrackViewedOnboardingTutorialUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class TrackViewedOnboardingTutorialUseCase {
    
    private let storeViewedRepository: StoreOnboardingTutorialViewedRepositoryInterface
    
    init(storeViewedRepository: StoreOnboardingTutorialViewedRepositoryInterface) {
        
        self.storeViewedRepository = storeViewedRepository
    }
    
    func viewedPublisher() -> AnyPublisher<Void, Never> {
        
        return storeViewedRepository.storeViewedPublisher()
            .eraseToAnyPublisher()
    }
}
