//
//  GetTranslatedToolCategory.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class GetTranslatedToolCategory {
    
    static let localizedKeyPrefix: String = "tool_category_"
    
    private let localizationServices: LocalizationServicesInterface
    private let resourcesRepository: ResourcesRepository
    
    init(localizationServices: LocalizationServicesInterface, resourcesRepository: ResourcesRepository) {
        
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
            key: "\(Self.localizedKeyPrefix)\(resource.attrCategory)"
        )
        
        return category
    }
}
