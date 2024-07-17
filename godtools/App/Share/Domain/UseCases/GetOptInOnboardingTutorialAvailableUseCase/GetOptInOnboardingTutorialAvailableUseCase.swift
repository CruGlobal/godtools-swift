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
        
    init() {
        
    }
        
    func getIsAvailablePublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<Bool, Never> {
        
        let isAvailable: Bool = appLanguage == LanguageCodeDomainModel.english.value
        
        return Just(isAvailable)
            .eraseToAnyPublisher()
    }
}
