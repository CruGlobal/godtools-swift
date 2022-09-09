//
//  UserDidSetSettingsPrimaryLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 7/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class UserDidSetSettingsPrimaryLanguageUseCase {
    
    private let languageSettingsRepository: LanguageSettingsRepository
    
    init(languageSettingsRepository: LanguageSettingsRepository) {
        
        self.languageSettingsRepository = languageSettingsRepository
    }
    
    func setPrimaryLanguage(language: LanguageDomainModel) {
        
        let primaryLanguageEqualsParallelLanguage: Bool = languageSettingsRepository.getParallelLanguageId() == language.dataModelId
        
        if primaryLanguageEqualsParallelLanguage {
            languageSettingsRepository.deleteParallelLanguage()
        }
        
        languageSettingsRepository.storePrimaryLanguage(id: language.dataModelId)
    }
}
