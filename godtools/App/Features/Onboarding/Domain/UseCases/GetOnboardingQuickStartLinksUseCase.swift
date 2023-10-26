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
    
    func getLinksPublisher(appLanguageCodeChangedPublisher: AnyPublisher<AppLanguageCodeDomainModel, Never>) -> AnyPublisher<[OnboardingQuickStartLinkDomainModel], Never> {
        
        return appLanguageCodeChangedPublisher
            .flatMap({ (appLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<[OnboardingQuickStartLinkDomainModel], Never> in
                
                return self.getLinksRepositoryInterface.getLinks(appLanguageCode: appLanguageCode)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
