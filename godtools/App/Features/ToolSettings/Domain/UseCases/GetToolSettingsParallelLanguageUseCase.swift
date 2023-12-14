//
//  GetToolSettingsParallelLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolSettingsParallelLanguageUseCase {
    
    private let getParallelLanguageRepository: GetToolSettingsParallelLanguageRepositoryInterface
    
    init(getParallelLanguageRepository: GetToolSettingsParallelLanguageRepositoryInterface) {
        
        self.getParallelLanguageRepository = getParallelLanguageRepository
    }
    
    func getLanguagePublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolSettingsToolLanguageDomainModel?, Never> {
        
        return getParallelLanguageRepository
            .getLanguagePublisher(translateInLanguage: translateInLanguage)
            .eraseToAnyPublisher()
    }
}
