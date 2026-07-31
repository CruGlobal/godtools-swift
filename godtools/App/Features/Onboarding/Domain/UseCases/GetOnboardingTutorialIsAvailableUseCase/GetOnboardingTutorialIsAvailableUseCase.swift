//
//  GetOnboardingTutorialIsAvailableUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

final class GetOnboardingTutorialIsAvailableUseCase: GetOnboardingTutorialIsAvailableUseCaseInterface {
    
    private let getOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailable
    
    init(getOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailable) {
        
        self.getOnboardingTutorialIsAvailable = getOnboardingTutorialIsAvailable
    }
    
    func execute() async -> Bool {
        
        let isAvailable: Bool = await getOnboardingTutorialIsAvailable.getIsAvailable()
        
        return isAvailable
    }
}
