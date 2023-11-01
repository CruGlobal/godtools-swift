//
//  GetSocialSignInInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetSocialSignInInterfaceStringsRepository: GetSocialSignInInterfaceStringsRepositoryInterface {
    
    init() {
        
    }
    
    func getStringsPublisher(translateInLanguage: AppLanguageCodeDomainModel) -> AnyPublisher<SocialSignInInterfaceStringsDomainModel, Never> {
        
        let interfaceStrings = SocialSignInInterfaceStringsDomainModel()
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
