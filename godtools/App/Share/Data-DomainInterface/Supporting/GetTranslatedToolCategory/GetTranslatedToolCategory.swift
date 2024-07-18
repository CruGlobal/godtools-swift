//
//  GetTranslatedToolCategory.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import LocalizationServices

class GetTranslatedToolCategory {
    
    private let languagesRepository: LanguagesRepository
    private let localizationServices: LocalizationServices
    private let resourcesRepository: ResourcesRepository
    
    init(languagesRepository: LanguagesRepository, localizationServices: LocalizationServices, resourcesRepository: ResourcesRepository) {
        
        self.languagesRepository = languagesRepository
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
        
        let localeId = translateInLanguage.localeId

        let category: String = localizationServices.stringForLocaleElseEnglish(
            localeIdentifier: localeId,
            key: "tool_category_\(resource.attrCategory)"
        )
        
        return category
    }
}
