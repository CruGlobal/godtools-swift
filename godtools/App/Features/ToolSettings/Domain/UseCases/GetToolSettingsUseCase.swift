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
        
        return AnyPublisher() {
            return try await self.asyncExecute(
                appLanguage: appLanguage,
                toolId: toolId,
                toolLanguageId: toolLanguageId,
                toolPrimaryLanguageId: toolPrimaryLanguageId,
                toolParallelLanguageId: toolParallelLanguageId
            )
        }
    }
    
    func asyncExecute(appLanguage: AppLanguageDomainModel, toolId: String, toolLanguageId: String, toolPrimaryLanguageId: String, toolParallelLanguageId: String?) async throws -> ToolSettingsDomainModel {
        
        let hasTips: Bool = try await getHasTips(toolId: toolId, toolLanguageId: toolLanguageId)
        let primaryLanguage: ToolSettingsToolLanguageDomainModel? = getLanguage(languageId: toolPrimaryLanguageId, translateInLanguage: appLanguage)
        let parallelLanguage: ToolSettingsToolLanguageDomainModel? = getLanguage(languageId: toolParallelLanguageId, translateInLanguage: appLanguage)
        
        return ToolSettingsDomainModel(
            hasTips: hasTips,
            primaryLanguage: primaryLanguage,
            parallelLanguage: parallelLanguage
        )
    }
    
    private func getHasTips(toolId: String, toolLanguageId: String) async throws -> Bool {
        
        guard let translation = translationsRepository.getLatestTranslation(resourceId: toolId, languageId: toolLanguageId) else {
            return false
        }
        
        return try await translationsRepository.getTranslationManifestFromCache(
            translation: translation,
            manifestParserType: .manifestOnly,
            includeRelatedFiles: false
        )
        .manifest
        .hasTips
    }
    
    private func getLanguage(languageId: String?, translateInLanguage: AppLanguageDomainModel) -> ToolSettingsToolLanguageDomainModel? {
        
        guard let languageId = languageId, let language = languagesRepository.getLanguage(id: languageId) else {
            return nil
        }
        
        let languageName: String = getTranslatedLanguageName.getLanguageName(
            language: language,
            translatedInLanguage: translateInLanguage
        )
        
        let toolSettingsLanguage = ToolSettingsToolLanguageDomainModel(
            dataModelId: language.id,
            languageName: languageName
        )
        
        return toolSettingsLanguage
    }
}
