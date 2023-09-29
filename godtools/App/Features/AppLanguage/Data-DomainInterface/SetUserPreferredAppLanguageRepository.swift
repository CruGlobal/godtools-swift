//
//  SetUserPreferredAppLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class SetUserPreferredAppLanguageRepository: SetUserPreferredAppLanguageRepositoryInterface {
    
    private let userAppLanguageRepository: UserAppLanguageRepository
    
    init(userAppLanguageRepository: UserAppLanguageRepository) {
        
        self.userAppLanguageRepository = userAppLanguageRepository
    }
    
    func setLanguagePublisher(appLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<AppLanguageCodeDomainModel, Never> {
        
        userAppLanguageRepository.storeLanguagePublisher(languageCode: appLanguageCode)
            .map { _ in
                return appLanguageCode
            }
            .eraseToAnyPublisher()
    }
}
