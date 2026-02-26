//
//  GetToolsListItems.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolsListItems {
 
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedToolName: GetTranslatedToolName
    private let getTranslatedToolCategory: GetTranslatedToolCategory
    private let getToolListItemInterfaceStringsRepository: GetToolListItemInterfaceStringsRepository
    private let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository, languagesRepository: LanguagesRepository, getTranslatedToolName: GetTranslatedToolName, getTranslatedToolCategory: GetTranslatedToolCategory, getToolListItemInterfaceStringsRepository: GetToolListItemInterfaceStringsRepository, getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolCategory = getTranslatedToolCategory
        self.getToolListItemInterfaceStringsRepository = getToolListItemInterfaceStringsRepository
        self.getTranslatedToolLanguageAvailability = getTranslatedToolLanguageAvailability
    }
    
    func mapToolsToListItemsPublisher(tools: [ResourceDataModel], appLanguage: AppLanguageDomainModel, languageIdForAvailabilityText: String?) -> AnyPublisher<[ToolListItemDomainModel], Never> {
       
        let languageForAvailabilityTextModel: LanguageDataModel?
        
        if let languageForAvailabilityTextId = languageIdForAvailabilityText {
            languageForAvailabilityTextModel = languagesRepository.persistence.getDataModelNonThrowing(id: languageForAvailabilityTextId)
        } else {
            languageForAvailabilityTextModel = nil
        }
        
        return getToolListItemInterfaceStringsRepository
            .getStringsPublisher(
                translateInLanguage: appLanguage
            )
            .map { (strings: ToolListItemInterfaceStringsDomainModel) in
             
                return tools.map { tool in
                        
                    let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel
                    
                    if let language = languageForAvailabilityTextModel {
                        toolLanguageAvailability = self.getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(resource: tool, language: language, translateInLanguage: appLanguage)
                    }
                    else {
                        toolLanguageAvailability = ToolLanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
                    }
                    
                    return ToolListItemDomainModel(
                        interfaceStrings: strings,
                        analyticsToolAbbreviation: tool.abbreviation,
                        dataModelId: tool.id,
                        bannerImageId: tool.attrBanner,
                        name: self.getTranslatedToolName.getToolName(resource: tool, translateInLanguage: appLanguage),
                        category: self.getTranslatedToolCategory.getTranslatedCategory(resource: tool, translateInLanguage: appLanguage),
                        isFavorited: self.favoritedResourcesRepository.getResourceIsFavorited(id: tool.id),
                        languageAvailability: toolLanguageAvailability
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}
