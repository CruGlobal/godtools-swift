//
//  SetUserPreferredAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class SetUserPreferredAppLanguageUseCase {
    
    private let setUserPreferredAppLanguageRepositoryInterface: SetUserPreferredAppLanguageRepositoryInterface
    
    init(setUserPreferredAppLanguageRepositoryInterface: SetUserPreferredAppLanguageRepositoryInterface) {
        
        self.setUserPreferredAppLanguageRepositoryInterface = setUserPreferredAppLanguageRepositoryInterface
    }
    
    func setLanguagePublisher(language: AppLanguageCodeDomainModel) -> AnyPublisher<AppLanguageCodeDomainModel, Never> {
        
        setUserPreferredAppLanguageRepositoryInterface.setLanguagePublisher(appLanguageCode: language)
            .eraseToAnyPublisher()
    }
}
