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
    
    init(getLanguageUseCase: GetLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, resourcesRepository: ResourcesRepository) {
        self.getLanguageUseCase = getLanguageUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.resourcesRepository = resourcesRepository
    }
    
    func getTool(resource: ResourceModel) -> ToolDomainModel {
        
        let primaryLanguage = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()
        let currentToolTranslation = getCurrentToolTranslation(for: resource, language: primaryLanguage)
        
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
    
    private func getCurrentToolTranslation(for resource: ResourceModel, language: LanguageDomainModel?) -> (language: LanguageDomainModel, translation: TranslationModel?)  {
                
        if let language = language, let translation = resourcesRepository.getResourceLanguageLatestTranslation(resourceId: resource.id, languageId: language.id) {
            
            return (language, translation)
            
        } else if let englishTranslation = resourcesRepository.getResourceLanguageLatestTranslation(resourceId: resource.id, languageId: LanguageCodes.english), let englishLanguageModel = englishTranslation.language {
            
            let englishLanguageDomainModel = getLanguageUseCase.getLanguage(language: englishLanguageModel)
            return (englishLanguageDomainModel, englishTranslation)
            
        } else {
            
            let englishLanguage = LanguageDomainModel(analyticsContentLanguage: LanguageCodes.english, dataModelId: "", direction: .leftToRight, localeIdentifier: LanguageCodes.english, translatedName: "English")
            
            return (englishLanguage, nil)
        }
    }
}
