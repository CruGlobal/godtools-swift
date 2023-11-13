//
//  GetOnboardingTutorialIsAvailableUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetOnboardingTutorialIsAvailableUseCase {
    
    private let getLaunchCountUseCase: GetLaunchCountUseCase
    private let getViewedRepositoryInterface: GetOnboardingTutorialViewedRepositoryInterface
    
    init(getLaunchCountUseCase: GetLaunchCountUseCase, getViewedRepositoryInterface: GetOnboardingTutorialViewedRepositoryInterface) {
        
        self.getLaunchCountUseCase = getLaunchCountUseCase
        self.getViewedRepositoryInterface = getViewedRepositoryInterface
    }
    
    func getAvailablePublisher() -> AnyPublisher<Bool, Never> {
                        
        Publishers.CombineLatest(
            getLaunchCountUseCase.getCountPublisher(),
            getViewedRepositoryInterface.getViewedPublisher()
        )
        .flatMap({ (launchCount: Int, tutorialViewed: Bool) -> AnyPublisher<Bool, Never> in
            
            let isAvailable = launchCount == 1 && !tutorialViewed
            
            return Just(isAvailable)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
