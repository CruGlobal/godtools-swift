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
    
    private let storeViewedRepositoryInterface: StoreOnboardingTutorialViewedRepositoryInterface
    
    init(storeViewedRepositoryInterface: StoreOnboardingTutorialViewedRepositoryInterface) {
        
        self.storeViewedRepositoryInterface = storeViewedRepositoryInterface
    }
    
    func viewedPublisher() -> AnyPublisher<Void, Never> {
        
        return storeViewedRepositoryInterface.storeViewedPublisher()
            .eraseToAnyPublisher()
    }
}
