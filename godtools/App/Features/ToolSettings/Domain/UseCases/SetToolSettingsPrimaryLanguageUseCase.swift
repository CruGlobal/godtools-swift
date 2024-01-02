//
//  SetToolSettingsPrimaryLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class SetToolSettingsPrimaryLanguageUseCase {
    
    private let storePrimaryLanguageRepository: StoreToolSettingsPrimaryLanguageRepositoryInterface
    
    init(storePrimaryLanguageRepository: StoreToolSettingsPrimaryLanguageRepositoryInterface) {
        
        self.storePrimaryLanguageRepository = storePrimaryLanguageRepository
    }
    
    func setLanguagePublisher(languageId: String) -> AnyPublisher<Void, Never> {
        
        return storePrimaryLanguageRepository
            .storeLanguagePublisher(languageId: languageId)
            .eraseToAnyPublisher()
    }
}
