//
//  SetAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class SetAppLanguageUseCase {
    
    private let setUserPreferredAppLanguageRepositoryInterface: SetUserPreferredAppLanguageRepositoryInterface
    
    init(setUserPreferredAppLanguageRepositoryInterface: SetUserPreferredAppLanguageRepositoryInterface) {
        
        self.setUserPreferredAppLanguageRepositoryInterface = setUserPreferredAppLanguageRepositoryInterface
    }
    
    func setLanguagePublisher(language: AppLanguageDomainModel) -> AnyPublisher<AppLanguageDomainModel, Never> {
        
        setUserPreferredAppLanguageRepositoryInterface.setLanguagePublisher(appLanguage: language)
            .eraseToAnyPublisher()
    }
}
