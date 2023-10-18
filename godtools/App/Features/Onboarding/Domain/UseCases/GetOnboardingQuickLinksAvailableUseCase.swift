//
//  GetOnboardingQuickLinksAvailableUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetOnboardingQuickLinksAvailableUseCase {
    
    private static let supportedLanguages: [LanguageCodeDomainModel] = [.english, .french, .latvian, .spanish, .vietnamese]
        
    init() {
        
    }
    
    func getAvailablePublisher(appLanguageCodeChangedPublisher: AnyPublisher<AppLanguageCodeDomainModel, Never>) -> AnyPublisher<Bool, Never> {
        
        return appLanguageCodeChangedPublisher
            .flatMap({ (appLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<Bool, Never> in
                
                let available: Bool = GetOnboardingQuickLinksAvailableUseCase
                    .supportedLanguages
                    .map({$0.value})
                    .contains(appLanguageCode)
                
                return Just(available)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
