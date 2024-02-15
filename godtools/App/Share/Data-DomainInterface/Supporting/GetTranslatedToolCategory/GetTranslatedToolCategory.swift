//
//  GetTranslatedToolCategory.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class GetTranslatedToolCategory {
    
    private let localizationServices: LocalizationServices
    private let resourcesRepository: ResourcesRepository
    
    init(localizationServices: LocalizationServices, resourcesRepository: ResourcesRepository) {
        
        self.localizationServices = localizationServices
        self.resourcesRepository = resourcesRepository
    }
    
    func getTranslatedCategory(toolId: String, translateInLanguage: BCP47LanguageIdentifier) -> String {
        
        guard let resource = resourcesRepository.getResource(id: toolId) else {
            return ""
        }
        
        return getTranslatedCategory(resource: resource, translateInLanguage: translateInLanguage)
    }
    
    func getTranslatedCategory(resource: ResourceModel, translateInLanguage: BCP47LanguageIdentifier) -> String {
                
        let category: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInLanguage, key: "tool_category_\(resource.attrCategory)")
        
        return category
    }
}
