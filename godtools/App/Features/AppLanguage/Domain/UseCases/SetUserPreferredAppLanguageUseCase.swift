//
//  SetUserPreferredAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class SetUserPreferredAppLanguageUseCase {
    
    private let setUserPreferredAppLanguageRepositoryInterface: SetUserPreferredAppLanguageRepositoryInterface
    
    init(setUserPreferredAppLanguageRepositoryInterface: SetUserPreferredAppLanguageRepositoryInterface) {
        
        self.setUserPreferredAppLanguageRepositoryInterface = setUserPreferredAppLanguageRepositoryInterface
    }
    
    func setAppLanguage(appLanguage: AppLanguageCodeDomainModel) {
        
        setUserPreferredAppLanguageRepositoryInterface.setAppLanguage(appLanguage: appLanguage)
    }
}
