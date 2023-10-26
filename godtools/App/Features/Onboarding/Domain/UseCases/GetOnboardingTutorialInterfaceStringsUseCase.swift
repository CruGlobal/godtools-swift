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
    
    func getStringsPublisher(appLanguageCodeChangedPublisher: AnyPublisher<AppLanguageCodeDomainModel, Never>) -> AnyPublisher<OnboardingTutorialInterfaceStringsDomainModel, Never> {
        
        return appLanguageCodeChangedPublisher
            .flatMap({ (appLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<OnboardingTutorialInterfaceStringsDomainModel, Never> in
                
                return self.getStringsRepositoryInterface.getStringsPublisher(appLanguageCode: appLanguageCode)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
