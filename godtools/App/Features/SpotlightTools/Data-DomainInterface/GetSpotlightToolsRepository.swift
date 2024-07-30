//
//  GetSpotlightToolsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetSpotlightToolsRepository: GetSpotlightToolsRepositoryInterface {
    
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
    
    func getSpotlightToolsPublisher(translatedInAppLanguage: AppLanguageDomainModel, languageIdForAvailabilityText: String?) -> AnyPublisher<[SpotlightToolListItemDomainModel], Never> {
        
        let languageForAvailabilityTextModel: LanguageModel?
        
        if let languageForAvailabilityTextId = languageIdForAvailabilityText {
            languageForAvailabilityTextModel = languagesRepository.getLanguage(id: languageForAvailabilityTextId)
        } else {
            languageForAvailabilityTextModel = nil
        }
        
        return Publishers.CombineLatest(
            resourcesRepository.getResourcesChangedPublisher(),
            getToolListItemInterfaceStringsRepository.getStringsPublisher(translateInLanguage: translatedInAppLanguage)
        )
        .flatMap({ (resourcesChanged: Void, interfaceStrings: ToolListItemInterfaceStringsDomainModel) -> AnyPublisher<[SpotlightToolListItemDomainModel], Never> in
        
            let spotlightToolResources: [ResourceModel] = self.resourcesRepository.getSpotlightTools(sortByDefaultOrder: true)

            let spotlightTools: [SpotlightToolListItemDomainModel] = spotlightToolResources
                .map({
                    
                    let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel
                    
                    if let language = languageForAvailabilityTextModel {
                        
                        toolLanguageAvailability = self.getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(resource: $0, language: language, translateInLanguage: translatedInAppLanguage)
                    }
                    else {
                        toolLanguageAvailability = ToolLanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
                    }
                    
                    return SpotlightToolListItemDomainModel(
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
            
            return Just(spotlightTools)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
}
