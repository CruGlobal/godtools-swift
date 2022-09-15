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
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let resourcesRepository: ResourcesRepository
    
    init(getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, resourcesRepository: ResourcesRepository) {
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
            currentTranslation: currentToolTranslation,
            dataModelId: resource.id,
            languageIds: resource.languageIds,
            name: getName(for: resource, from: currentToolTranslation),
            resource: resource
        )
    }
    
    private func getCurrentToolTranslation(for resource: ResourceModel, language: LanguageDomainModel?) -> CurrentToolTranslationDomainModel {
                
        if let language = language, let translation = resourcesRepository.getResourceLanguageLatestTranslation(resourceId: resource.id, languageId: language.id) {
            
            return .primaryLanguage(language: language, translation: translation)
            
        } else if let englishTranslation = resourcesRepository.getResourceLanguageLatestTranslation(resourceId: resource.id, languageId: LanguageCodes.english) {
            
            return .englishFallback(translation: englishTranslation)
            
        } else {
            
            return .englishFallback(translation: nil)
        }
    }
    
    private func getName(for resource: ResourceModel, from currentToolTranslation: CurrentToolTranslationDomainModel) -> String {
                
        switch currentToolTranslation {
        case .primaryLanguage(_, let translation):
            return translation.translatedName
            
        case .englishFallback(let translation):
            return translation?.translatedName ?? resource.name
        }
    }
}
