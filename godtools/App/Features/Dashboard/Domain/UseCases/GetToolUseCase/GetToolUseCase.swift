//
//  GetToolUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolUseCase {
    
    private let getLanguageUseCase: GetLanguageUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    
    init(getLanguageUseCase: GetLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) {
        self.getLanguageUseCase = getLanguageUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
    }
    
    func getTool(id: String) -> ToolDomainModel? {
        
        guard let resource = resourcesRepository.getResource(id: id) else {
            return nil
        }
        
        return getTool(resource: resource)
        
    }
    
    func getTool(resource: ResourceModel) -> ToolDomainModel {
        
        let primaryLanguage: LanguageDomainModel? = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()
        let currentToolTranslation: (language: LanguageDomainModel, translation: TranslationModel?) = getCurrentToolTranslation(for: resource, language: primaryLanguage)
        
        return ToolDomainModel(
            abbreviation: resource.abbreviation,
            bannerImageId: resource.attrBanner,
            category: resource.attrCategory,
            currentTranslationLanguage: currentToolTranslation.language,
            dataModelId: resource.id,
            languageIds: resource.languageIds,
            name: currentToolTranslation.translation?.translatedName ?? resource.name,
            resource: resource
        )
    }
    
    private func getCurrentToolTranslation(for resource: ResourceModel, language: LanguageDomainModel?) -> (language: LanguageDomainModel, translation: TranslationModel?) {
                
        if let language = language, let translation = translationsRepository.getLatestTranslation(resourceId: resource.id, languageId: language.id) {
            
            return (language: language, translation: translation)
            
        }
        else if let englishTranslation = translationsRepository.getLatestTranslation(resourceId: resource.id, languageId: LanguageCodeDomainModel.english.value), let englishLanguageModel = englishTranslation.language {
            
            let englishLanguageDomainModel = getLanguageUseCase.getLanguage(language: englishLanguageModel)
            
            return (language: englishLanguageDomainModel, translation: englishTranslation)
        }
        else {
            
            let englishLanguage = LanguageDomainModel(analyticsContentLanguage: LanguageCodeDomainModel.english.value, dataModelId: "", direction: .leftToRight, localeIdentifier: LanguageCodeDomainModel.english.value, translatedName: "English")
            
            return (language: englishLanguage, translation: nil)
        }
    }
}
