//
//  GetSocialCreateAccountInterfaceStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 11/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetSocialCreateAccountInterfaceStringsUseCase {
    
    private let getInterfaceStringsRepositoryInterface: GetSocialCreateAccountInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepositoryInterface: GetSocialCreateAccountInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepositoryInterface = getInterfaceStringsRepositoryInterface
    }
    
    func getStringsPublisher(appLanguagePublisher: AnyPublisher<AppLanguageDomainModel, Never>) -> AnyPublisher<SocialCreateAccountInterfaceStringsDomainModel, Never> {
        
        return appLanguagePublisher
            .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<SocialCreateAccountInterfaceStringsDomainModel, Never> in
                
                return self.getInterfaceStringsRepositoryInterface.getStringsPublisher(translateInLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
