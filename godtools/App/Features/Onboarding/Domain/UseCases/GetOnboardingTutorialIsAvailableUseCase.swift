//
//  GetOnboardingTutorialIsAvailableUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetOnboardingTutorialIsAvailableUseCase {
    
    private let getOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailable
    
    init(getOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailable) {
        
        self.getOnboardingTutorialIsAvailable = getOnboardingTutorialIsAvailable
    }
    
    func execute() -> AnyPublisher<Bool, Never> {
        
        let isAvailable: Bool = getOnboardingTutorialIsAvailable.getIsAvailable()
        
        return Just(isAvailable)
            .eraseToAnyPublisher()
    }
}
