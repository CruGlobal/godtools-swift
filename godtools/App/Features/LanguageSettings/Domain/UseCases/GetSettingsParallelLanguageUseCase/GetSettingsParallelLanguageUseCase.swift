//
//  GetSettingsParallelLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 7/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

@available(*, deprecated) // TODO: This will need to be removed once we finish refactor for tracking analytics property cru_contentlanguagesecondary in GT-2135. ~Levi
class GetSettingsParallelLanguageUseCase {
    
    private let languagesRepository: LanguagesRepository
    private let languageSettingsRepository: LanguageSettingsRepository
    private let getLanguageUseCase: GetLanguageUseCase
    
    init(languagesRepository: LanguagesRepository, languageSettingsRepository: LanguageSettingsRepository, getLanguageUseCase: GetLanguageUseCase) {
        
        self.languagesRepository = languagesRepository
        self.languageSettingsRepository = languageSettingsRepository
        self.getLanguageUseCase = getLanguageUseCase
    }
    
    func getParallelLanguage() -> LanguageDomainModel? {
        return nil
    }
}
