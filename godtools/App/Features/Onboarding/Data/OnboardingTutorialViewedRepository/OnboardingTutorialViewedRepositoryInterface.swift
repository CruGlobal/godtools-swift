//
//  OnboardingTutorialViewedRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

protocol OnboardingTutorialViewedRepositoryInterface {
    
    func getOnboardingTutorialViewed() -> Bool
    func getOnboardingTutorialViewedPublisher() -> AnyPublisher<Bool, Never>
    func storeOnboardingTutorialViewed(viewed: Bool)
}
