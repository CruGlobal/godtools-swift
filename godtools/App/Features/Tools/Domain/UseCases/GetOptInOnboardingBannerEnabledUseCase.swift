//
//  GetOptInOnboardingBannerEnabledUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetOptInOnboardingBannerEnabledUseCase {
    
    private let getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase
    private let optInOnboardingBannerEnabledRepository: OptInOnboardingBannerEnabledRepository
    
    init(getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase, optInOnboardingBannerEnabledRepository: OptInOnboardingBannerEnabledRepository) {
        
        self.getTutorialIsAvailableUseCase = getTutorialIsAvailableUseCase
        self.optInOnboardingBannerEnabledRepository = optInOnboardingBannerEnabledRepository
    }
        
    func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<Bool, Never> {
        
        let tutorialAvailable: Bool = getTutorialIsAvailableUseCase.execute(appLanguage: appLanguage)
        
        return optInOnboardingBannerEnabledRepository
            .getEnabledPublisher()
            .map { (bannerEnabled: Bool) in
                
                return tutorialAvailable && bannerEnabled
            }
            .eraseToAnyPublisher()
    }
}
