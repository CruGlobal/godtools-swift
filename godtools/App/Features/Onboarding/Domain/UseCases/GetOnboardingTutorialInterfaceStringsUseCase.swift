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
    
    private let getStringsRepositoryInterface: GetOnboardingTutorialInterfaceStringsRepositoryInterface
    
    init(getStringsRepositoryInterface: GetOnboardingTutorialInterfaceStringsRepositoryInterface) {
        
        self.getStringsRepositoryInterface = getStringsRepositoryInterface
    }
    
    func getStringsPublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<OnboardingTutorialInterfaceStringsDomainModel, Never> {
        
        return getStringsRepositoryInterface
            .getStringsPublisher(appLanguage: appLanguage)
            .eraseToAnyPublisher()
    }
}
