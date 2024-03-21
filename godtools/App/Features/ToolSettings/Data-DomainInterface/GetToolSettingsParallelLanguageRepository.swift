//
//  GetToolSettingsParallelLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolSettingsParallelLanguageRepository: GetToolSettingsParallelLanguageRepositoryInterface {
    
    private let languagesRepository: LanguagesRepository
    private let translatedLanguageNameRepository: TranslatedLanguageNameRepository
    
    init(languagesRepository: LanguagesRepository, translatedLanguageNameRepository: TranslatedLanguageNameRepository) {
        
        self.languagesRepository = languagesRepository
        self.translatedLanguageNameRepository = translatedLanguageNameRepository
    }
    
    func getLanguagePublisher(parallelLanguageId: String?, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolSettingsToolLanguageDomainModel?, Never> {
        
        guard let languageId = parallelLanguageId, let language = languagesRepository.getLanguage(id: languageId) else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        
        let languageName: String = translatedLanguageNameRepository.getLanguageName(
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
