//
//  SetUserPreferredAppLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class SetUserPreferredAppLanguageRepository: SetUserPreferredAppLanguageRepositoryInterface {
    
    private let userAppLanguageRepository: UserAppLanguageRepository
    
    init(userAppLanguageRepository: UserAppLanguageRepository) {
        
        self.userAppLanguageRepository = userAppLanguageRepository
    }
    
    func setAppLanguage(appLanguage: AppLanguageCodeDomainModel) {
        
        userAppLanguageRepository.storeUserAppLanguage(languageCode: appLanguage)
    }
}
