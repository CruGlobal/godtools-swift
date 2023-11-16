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
    
    func getStringsPublisher(appLanguagePublisher: AnyPublisher<AppLanguageDomainModel, Never>) -> AnyPublisher<OnboardingQuickStartInterfaceStringsDomainModel, Never> {
        
        return appLanguagePublisher
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<OnboardingQuickStartInterfaceStringsDomainModel, Never> in
                
                return self.getStringsRepositoryInterface.getStringsPublisher(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
