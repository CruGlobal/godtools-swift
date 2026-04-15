//
//  GetToolSettingsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolSettingsUseCase {
    
    private let translationsRepository: TranslationsRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedLanguageName: GetTranslatedLanguageName
    
    init(translationsRepository: TranslationsRepository, languagesRepository: LanguagesRepository, getTranslatedLanguageName: GetTranslatedLanguageName) {
        
        self.translationsRepository = translationsRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedLanguageName = getTranslatedLanguageName
    }
    
    func execute(appLanguage: AppLanguageDomainModel, toolId: String, toolLanguageId: String, toolPrimaryLanguageId: String, toolParallelLanguageId: String?) -> AnyPublisher<ToolSettingsDomainModel, Error> {
        
        return Publishers.CombineLatest3(
            getHasTipsPublisher(toolId: toolId, toolLanguageId: toolLanguageId),
            getLanguagePublisher(languageId: toolPrimaryLanguageId, translateInLanguage: appLanguage)
                .setFailureType(to: Error.self),
            getLanguagePublisher(languageId: toolParallelLanguageId, translateInLanguage: appLanguage)
                .setFailureType(to: Error.self)
        )
        .map {
            
            let domainModel = ToolSettingsDomainModel(
                hasTips: $0,
                primaryLanguage: $1,
                parallelLanguage: $2
            )
            
            return domainModel
        }
        .eraseToAnyPublisher()
    }
    
    private func getHasTipsPublisher(toolId: String, toolLanguageId: String) -> AnyPublisher<Bool, Error> {
        
        guard let translation = translationsRepository.cache.getLatestTranslation(resourceId: toolId, languageId: toolLanguageId) else {
            return Just(false)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return translationsRepository.getTranslationManifestFromCache(translation: translation, manifestParserType: .manifestOnly, includeRelatedFiles: false)
            .map {
                return $0.manifest.hasTips
            }
            .eraseToAnyPublisher()
    }
    
    private func getLanguagePublisher(languageId: String?, translateInLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolSettingsToolLanguageDomainModel?, Never> {
        
        guard let languageId = languageId, let language = languagesRepository.persistence.getDataModelNonThrowing(id: languageId) else {
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
