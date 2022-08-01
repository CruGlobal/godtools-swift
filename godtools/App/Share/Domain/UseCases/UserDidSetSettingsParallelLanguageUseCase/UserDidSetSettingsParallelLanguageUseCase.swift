//
//  UserDidSetSettingsParallelLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 7/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class UserDidSetSettingsParallelLanguageUseCase {
    
    private let languageSettingsRepository: LanguageSettingsRepository
    
    init(languageSettingsRepository: LanguageSettingsRepository) {
        
        self.languageSettingsRepository = languageSettingsRepository
    }
    
    func setParallelLanguage(language: LanguageDomainModel) {
        
        languageSettingsRepository.storeParallelLanguage(id: language.dataModelId)
    }
}
