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
    
    private let onboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailableInterface
        
    init(onboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailableInterface) {
        
        self.onboardingTutorialIsAvailable = onboardingTutorialIsAvailable
    }
    
    func getAvailablePublisher() -> AnyPublisher<Bool, Never> {
          
        return onboardingTutorialIsAvailable
            .isAvailablePublisher()
            .eraseToAnyPublisher()
    }
}
