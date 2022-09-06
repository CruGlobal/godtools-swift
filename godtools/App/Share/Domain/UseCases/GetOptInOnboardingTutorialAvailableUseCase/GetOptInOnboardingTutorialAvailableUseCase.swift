//
//  GetOptInOnboardingTutorialAvailableUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetOptInOnboardingTutorialAvailableUseCase {
    
    private let getDeviceLanguageUseCase: GetDeviceLanguageUseCase
    
    required init(getDeviceLanguageUseCase: GetDeviceLanguageUseCase) {
        
        self.getDeviceLanguageUseCase = getDeviceLanguageUseCase
    }
        
    func getOptInOnboardingTutorialIsAvailable() -> Bool {
        
        return getDeviceLanguageUseCase.getDeviceLanguage().localeLanguageCode == LanguageCodes.english
    }
    
    func getOptInOnboardingTutorialIsAvailable() -> AnyPublisher<Bool, Never> {
        
        return Just(getOptInOnboardingTutorialIsAvailable())
            .eraseToAnyPublisher()
    }
}
