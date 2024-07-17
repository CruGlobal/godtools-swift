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
    
    func setLanguagePublisher(appLanguage: AppLanguageDomainModel) -> AnyPublisher<AppLanguageDomainModel, Never> {
        
        userAppLanguageRepository.storeLanguagePublisher(languageId: appLanguage)
            .map { _ in
                return appLanguage
            }
            .eraseToAnyPublisher()
    }
}
