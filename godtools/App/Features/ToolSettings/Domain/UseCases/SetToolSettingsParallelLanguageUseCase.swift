//
//  SetToolSettingsParallelLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class SetToolSettingsParallelLanguageUseCase {
    
    private let storeParallelLanguageRepository: StoreToolSettingsParallelLanguageRepositoryInterface
    
    init(storeParallelLanguageRepository: StoreToolSettingsParallelLanguageRepositoryInterface) {
        
        self.storeParallelLanguageRepository = storeParallelLanguageRepository
    }
    
    func storeLanguagePublisher(languageId: String) -> AnyPublisher<Void, Never> {
        
        return storeParallelLanguageRepository
            .storeLanguagePublisher(languageId: languageId)
            .eraseToAnyPublisher()
    }
}
