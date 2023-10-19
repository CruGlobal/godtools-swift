//
//  GetOnboardingQuickStartInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetOnboardingQuickStartInterfaceStringsRepository: GetOnboardingQuickStartInterfaceStringsRepositoryInterface {
    
    private let localizationServices: LocalizationServices
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
    }
    
    func getStringsPublisher(appLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<OnboardingQuickStartInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings = OnboardingQuickStartInterfaceStringsDomainModel(
            title: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingQuickStart.title"),
            getStartedButtonTitle: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguageCode, key: "onboardingTutorial.getStartedButton.title")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
