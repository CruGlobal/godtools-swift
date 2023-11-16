//
//  GetOnboardingQuickStartLinksUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 3/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetOnboardingQuickStartLinksUseCase {
    
    private let getLinksRepositoryInterface: GetOnboardingQuickStartLinksRepositoryInterface
    
    init(getLinksRepositoryInterface: GetOnboardingQuickStartLinksRepositoryInterface) {
        
        self.getLinksRepositoryInterface = getLinksRepositoryInterface
    }
    
    func getLinksPublisher(appLanguagePublisher: AnyPublisher<AppLanguageDomainModel, Never>) -> AnyPublisher<[OnboardingQuickStartLinkDomainModel], Never> {
        
        return appLanguagePublisher
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<[OnboardingQuickStartLinkDomainModel], Never> in
                
                return self.getLinksRepositoryInterface.getLinks(appLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
