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
    
    private var getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let resourcesRepository: ResourcesRepository
    
    init(getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, resourcesRepository: ResourcesRepository) {
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.resourcesRepository = resourcesRepository
    }
    
    func getTool(resource: ResourceModel) -> ToolDomainModel {
        
        let currentTranslationPublisher =
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .flatMap { language -> AnyPublisher<CurrentToolTranslationDomainModel, Never> in
                
                let currentTranslationToUse = self.getCurrentToolTranslation(for: resource, language: language)
                                
                return Just(currentTranslationToUse)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        let namePublisher = getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .flatMap { language -> AnyPublisher<String, Never> in
                
                let translatedName = self.getName(for: resource, language: language)
                                
                return Just(translatedName)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        return ToolDomainModel(
            bannerImageId: resource.attrBanner,
            category: resource.attrCategory,
            currentTranslationPublisher: currentTranslationPublisher,
            dataModelId: resource.id,
            languageIds: resource.languageIds,
            namePublisher: namePublisher,
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
    
    private func getName(for resource: ResourceModel, language: LanguageDomainModel?) -> String {
        
        guard let language = language else { return resource.name }
        let translationToUse = getCurrentToolTranslation(for: resource, language: language)
        
        switch translationToUse {
        case .primaryLanguage(_, let translation):
            return translation.translatedName
            
        case .englishFallback(let translation):
            return translation?.translatedName ?? resource.name
        }
    }
}
