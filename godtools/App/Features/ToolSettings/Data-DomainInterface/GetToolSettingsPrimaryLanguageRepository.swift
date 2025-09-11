//
//  GetToolSettingsPrimaryLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolSettingsPrimaryLanguageRepository: GetToolSettingsPrimaryLanguageRepositoryInterface {
    
    private let languagesRepository: LanguagesRepository
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    
    init(languagesRepository: LanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName) {
        
        self.languagesRepository = languagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
    }
    
    func getLanguagePublisher(primaryLanguageId: String, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolSettingsToolLanguageDomainModel?, Never> {
        
        guard let language = languagesRepository.getCachedObject(id: primaryLanguageId) else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        
        let languageName: String = getTranslatedLanguageName.getLanguageName(
            language: language,
            translatedInLanguage: translateInLanguage
        )
        
        let toolSettingsLanguage = ToolSettingsToolLanguageDomainModel(
            dataModelId: language.id,
            languageName: languageName
        )
        
        return Just(toolSettingsLanguage)
            .eraseToAnyPublisher()
    }
}
