//
//  GetTranslatedToolName.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class GetTranslatedToolName {
    
    private let resourcesRepository: ResourcesRepository
    private let translationsRepository: TranslationsRepository
    
    init(resourcesRepository: ResourcesRepository, translationsRepository: TranslationsRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.translationsRepository = translationsRepository
    }
    
    func getToolName(toolId: String, translateInLanguage: BCP47LanguageIdentifier) -> String {
        
        guard let resource = resourcesRepository.persistence.getObject(id: toolId) else {
            return ""
        }
        
        return getToolName(resource: resource, translateInLanguage: translateInLanguage)
    }
    
    func getToolName(resource: ResourceDataModel, translateInLanguage: BCP47LanguageIdentifier) -> String {
        
        if let languageTranslation = translationsRepository.cache.getLatestTranslation(resourceId: resource.id, languageCode: translateInLanguage) {
            
            return languageTranslation.translatedName
        }
        else if let defaultLanguageTranslation = translationsRepository.cache.getLatestTranslation(resourceId: resource.id, languageCode: resource.attrDefaultLocale) {
            
            return defaultLanguageTranslation.translatedName
        }
        
        return resource.name
    }
}
