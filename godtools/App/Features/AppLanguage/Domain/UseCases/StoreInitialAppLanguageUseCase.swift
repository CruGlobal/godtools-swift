//
//  StoreInitialAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreInitialAppLanguageUseCase {
    
    private let storeInitialAppLanguage: StoreInitialAppLanguageInterface
    
    init(storeInitialAppLanguage: StoreInitialAppLanguageInterface) {
        
        self.storeInitialAppLanguage = storeInitialAppLanguage
    }
    
    func storeInitialAppLanguagePublisher() -> AnyPublisher<AppLanguageDomainModel, Never> {
        
        return storeInitialAppLanguage
            .storeInitialAppLanguagePublisher()
            .eraseToAnyPublisher()
    }
}
