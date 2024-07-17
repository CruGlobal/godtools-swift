//
//  GetToolsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolsRepository: GetToolsRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedToolName: GetTranslatedToolName
    private let getTranslatedToolCategory: GetTranslatedToolCategory
    private let getToolListItemInterfaceStringsRepository: GetToolListItemInterfaceStringsRepository
    private let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    
    init(resourcesRepository: ResourcesRepository, favoritedResourcesRepository: FavoritedResourcesRepository, languagesRepository: LanguagesRepository, getTranslatedToolName: GetTranslatedToolName, getTranslatedToolCategory: GetTranslatedToolCategory, getToolListItemInterfaceStringsRepository: GetToolListItemInterfaceStringsRepository, getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability) {
        
        self.resourcesRepository = resourcesRepository
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolCategory = getTranslatedToolCategory
        self.getToolListItemInterfaceStringsRepository = getToolListItemInterfaceStringsRepository
        self.getTranslatedToolLanguageAvailability = getTranslatedToolLanguageAvailability
    }
    
    func getToolsPublisher(translatedInAppLanguage: AppLanguageDomainModel, languageForAvailabilityText: LanguageDomainModel?, filterToolsByCategory: CategoryFilterDomainModel?, filterToolsByLanguage: LanguageFilterDomainModel?) -> AnyPublisher<[ToolListItemDomainModel], Never> {
        
        let languageForAvailabilityTextModel: LanguageModel? 
        
        if let languageForAvailabilityTextId = languageForAvailabilityText?.id {
            languageForAvailabilityTextModel = languagesRepository.getLanguage(id: languageForAvailabilityTextId)
        } else {
            languageForAvailabilityTextModel = nil
        }
        
        return Publishers.CombineLatest(
            resourcesRepository.getResourcesChangedPublisher().prepend(Void()),
            getToolListItemInterfaceStringsRepository.getStringsPublisher(translateInLanguage: translatedInAppLanguage)
        )
        .flatMap({ (resourcesChanged: Void, interfaceStrings: ToolListItemInterfaceStringsDomainModel) -> AnyPublisher<[ToolListItemDomainModel], Never> in
        
            let tools: [ResourceModel] = self.resourcesRepository.getAllToolsList(
                filterByCategory: filterToolsByCategory?.id,
                filterByLanguageId: filterToolsByLanguage?.id,
                sortByDefaultOrder: true
            )

            let toolListItems: [ToolListItemDomainModel] = tools
                .map({
                    
                    let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel
                    
                    if let language = languageForAvailabilityTextModel {
                        toolLanguageAvailability = self.getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(resource: $0, language: language, translateInLanguage: translatedInAppLanguage)
                    }
                    else {
                        toolLanguageAvailability = ToolLanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
                    }
                    
                    return ToolListItemDomainModel(
                        interfaceStrings: interfaceStrings,
                        analyticsToolAbbreviation: $0.abbreviation,
                        dataModelId: $0.id,
                        bannerImageId: $0.attrBanner,
                        name: self.getTranslatedToolName.getToolName(resource: $0, translateInLanguage: translatedInAppLanguage),
                        category: self.getTranslatedToolCategory.getTranslatedCategory(resource: $0, translateInLanguage: translatedInAppLanguage),
                        isFavorited: self.favoritedResourcesRepository.getResourceIsFavorited(id: $0.id),
                        languageAvailability: toolLanguageAvailability
                    )
                })
            
            return Just(toolListItems)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
