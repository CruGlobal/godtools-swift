//
//  GetToolSettingsPrimaryLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolSettingsPrimaryLanguageUseCase {
    
    private let getPrimaryLanguageRepository: GetToolSettingsPrimaryLanguageRepositoryInterface
    
    init(getPrimaryLanguageRepository: GetToolSettingsPrimaryLanguageRepositoryInterface) {
        
        self.getPrimaryLanguageRepository = getPrimaryLanguageRepository
    }
    
    func getLanguagePublisher(translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolSettingsToolLanguageDomainModel?, Never> {
        
        return getPrimaryLanguageRepository
            .getLanguagePublisher(translateInLanguage: translateInLanguage)
            .eraseToAnyPublisher()
    }
}
