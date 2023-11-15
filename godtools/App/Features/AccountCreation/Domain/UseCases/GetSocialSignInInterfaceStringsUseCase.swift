//
//  GetSocialSignInInterfaceStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetSocialSignInInterfaceStringsUseCase {
    
    private let getInterfaceStringsRepositoryInterface: GetSocialSignInInterfaceStringsRepositoryInterface
    
    init(getInterfaceStringsRepositoryInterface: GetSocialSignInInterfaceStringsRepositoryInterface) {
        
        self.getInterfaceStringsRepositoryInterface = getInterfaceStringsRepositoryInterface
    }
    
    func getStringsPublisher(appLanguagePublisher: AnyPublisher<AppLanguageCodeDomainModel, Never>) -> AnyPublisher<SocialSignInInterfaceStringsDomainModel, Never> {
        
        return appLanguagePublisher
            .flatMap({ (appLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<SocialSignInInterfaceStringsDomainModel, Never> in
                
                return self.getInterfaceStringsRepositoryInterface.getStringsPublisher(translateInLanguage: appLanguage)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
