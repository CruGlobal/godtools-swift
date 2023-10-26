//
//  GetOnboardingQuickStartInterfaceStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetOnboardingQuickStartInterfaceStringsUseCase {
    
    private let getStringsRepositoryInterface: GetOnboardingQuickStartInterfaceStringsRepositoryInterface
    
    init(getStringsRepositoryInterface: GetOnboardingQuickStartInterfaceStringsRepositoryInterface) {
        
        self.getStringsRepositoryInterface = getStringsRepositoryInterface
    }
    
    func getStringsPublisher(appLanguageCodeChangedPublisher: AnyPublisher<AppLanguageCodeDomainModel, Never>) -> AnyPublisher<OnboardingQuickStartInterfaceStringsDomainModel, Never> {
        
        return appLanguageCodeChangedPublisher
            .flatMap({ (appLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<OnboardingQuickStartInterfaceStringsDomainModel, Never> in
                
                return self.getStringsRepositoryInterface.getStringsPublisher(appLanguageCode: appLanguageCode)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
