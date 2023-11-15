//
//  GetOnboardingQuickStartIsAvailableUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetOnboardingQuickStartIsAvailableUseCase {
    
    private let getSupportedLanguagesRepositoryInterface: GetOnboardingQuickStartSupportedLanguagesRepositoryInterface
    
    init(getSupportedLanguagesRepositoryInterface: GetOnboardingQuickStartSupportedLanguagesRepositoryInterface) {
        
        self.getSupportedLanguagesRepositoryInterface = getSupportedLanguagesRepositoryInterface
    }
    
    func getAvailablePublisher(appLanguagePublisher: AnyPublisher<AppLanguageCodeDomainModel, Never>) -> AnyPublisher<Bool, Never> {
        
        return Publishers.CombineLatest(
            appLanguagePublisher,
            getSupportedLanguagesRepositoryInterface.getLanguagesPublisher()
        )
        .flatMap({ (appLanguageCode: AppLanguageCodeDomainModel, supportedLanguages: [LanguageCodeDomainModel]) -> AnyPublisher<Bool, Never> in
            
            let available: Bool = supportedLanguages
                .map({$0.value})
                .contains(appLanguageCode)
            
            return Just(available)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
