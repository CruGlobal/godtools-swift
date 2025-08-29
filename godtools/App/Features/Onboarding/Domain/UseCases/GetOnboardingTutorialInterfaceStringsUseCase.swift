//
//  GetOnboardingTutorialInterfaceStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetOnboardingTutorialInterfaceStringsUseCase {
    
    private let stringsRepository: GetOnboardingTutorialInterfaceStringsRepositoryInterface
    
    init(stringsRepository: GetOnboardingTutorialInterfaceStringsRepositoryInterface) {
        
        self.stringsRepository = stringsRepository
    }
    
    func getStringsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<OnboardingTutorialInterfaceStringsDomainModel, Never> {
        
        return stringsRepository
            .getStringsPublisher(appLanguage: appLanguage)
            .eraseToAnyPublisher()
    }
}
