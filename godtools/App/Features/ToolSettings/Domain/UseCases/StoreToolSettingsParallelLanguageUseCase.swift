//
//  StoreToolSettingsParallelLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreToolSettingsParallelLanguageUseCase {
    
    private let storeParallelLanguageRepository: StoreToolSettingsParallelLanguageRepositoryInterface
    
    init(storeParallelLanguageRepository: StoreToolSettingsParallelLanguageRepositoryInterface) {
        
        self.storeParallelLanguageRepository = storeParallelLanguageRepository
    }
    
    func storeLanguagePublisher(language: ToolSettingsToolLanguageDomainModel) -> AnyPublisher<Void, Never> {
        
        return storeParallelLanguageRepository
            .storeLanguagePublisher(language: language)
            .eraseToAnyPublisher()
    }
}
