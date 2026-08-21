//
//  GetToolsListItems.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class GetToolsListItems: Sendable {
 
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedToolName: GetTranslatedToolName
    private let getTranslatedToolCategory: GetTranslatedToolCategory
    private let getToolListItemStrings: GetToolListItemStrings
    private let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    
    init(
        favoritedResourcesRepository: FavoritedResourcesRepository,
        languagesRepository: LanguagesRepository,
        getTranslatedToolName: GetTranslatedToolName,
        getTranslatedToolCategory: GetTranslatedToolCategory,
        getToolListItemStrings: GetToolListItemStrings,
        getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    ) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolCategory = getTranslatedToolCategory
        self.getToolListItemStrings = getToolListItemStrings
        self.getTranslatedToolLanguageAvailability = getTranslatedToolLanguageAvailability
    }
    
    func mapToolsToListItems(tools: [ResourceDataModel], appLanguage: AppLanguageDomainModel, languageIdForAvailabilityText: String?) async -> [ToolListItemDomainModel] {

        let languageForAvailabilityTextModel: LanguageDataModel?

        if let languageForAvailabilityTextId = languageIdForAvailabilityText {
            languageForAvailabilityTextModel = languagesRepository.getLanguageById(id: languageForAvailabilityTextId)
        } else {
            languageForAvailabilityTextModel = nil
        }

        let strings: ToolListItemStringsDomainModel = getToolListItemStrings.getStrings(appLanguage: appLanguage)

        var toolListItems: [ToolListItemDomainModel] = Array()

        for tool in tools {

            let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel

            if let language = languageForAvailabilityTextModel {
                toolLanguageAvailability = self.getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(resource: tool, language: language, translateInLanguage: appLanguage)
            }
            else {
                toolLanguageAvailability = ToolLanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
            }

            toolListItems.append(
                ToolListItemDomainModel(
                    strings: strings,
                    analyticsToolAbbreviation: tool.abbreviation,
                    dataModelId: tool.id,
                    bannerImageId: tool.attrBanner,
                    name: getTranslatedToolName.getToolName(resource: tool, translateInLanguage: appLanguage),
                    category: await getTranslatedToolCategory.getTranslatedCategory(resource: tool, translateInLanguage: appLanguage),
                    isFavorited: favoritedResourcesRepository.getResourceIsFavorited(id: tool.id),
                    languageAvailability: toolLanguageAvailability
                )
            )
        }

        return toolListItems
    }
}
