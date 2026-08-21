//
//  GetTranslatedToolCategory.swift
//  godtools
//
//  Created by Levi Eggert on 2/15/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GetTranslatedToolCategory: Sendable {
    
    static let localizedKeyPrefix: String = "tool_category_"
    
    private let localizationServices: LocalizationServicesInterface
    private let resourcesRepository: ResourcesRepository
    
    init(localizationServices: LocalizationServicesInterface, resourcesRepository: ResourcesRepository) {
        
        self.localizationServices = localizationServices
        self.resourcesRepository = resourcesRepository
    }
    
    func getTranslatedCategory(toolId: String, translateInLanguage: BCP47LanguageIdentifier) -> String {
        
        guard let resource = resourcesRepository.getResourceById(id: toolId) else {
            return ""
        }
        
        return getTranslatedCategory(resource: resource, translateInLanguage: translateInLanguage)
    }
    
    func getTranslatedCategory(
        resource: ResourceDataModel,
        translateInLanguage: BCP47LanguageIdentifier
    ) -> String {
        
        let localeId = translateInLanguage.localeId

        let categoryKey: String = "\(Self.localizedKeyPrefix)\(resource.attrCategory)"

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                categoryKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: localeId),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        let category: String = strings[categoryKey] ?? ""
        
        return category
    }
}
