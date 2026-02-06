//
//  GetSpotlightToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetSpotlightToolsUseCase {
        
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
    
    @MainActor func execute(translatedInAppLanguage: AppLanguageDomainModel, languageIdForAvailabilityText: String?) -> AnyPublisher<[SpotlightToolListItemDomainModel], Error> {
        
        let languageForAvailabilityTextModel: LanguageDataModel?
        
        if let languageForAvailabilityTextId = languageIdForAvailabilityText {
            languageForAvailabilityTextModel = languagesRepository.persistence.getDataModelNonThrowing(id: languageForAvailabilityTextId)
        } else {
            languageForAvailabilityTextModel = nil
        }
        
        return Publishers.CombineLatest(
            resourcesRepository.persistence.observeCollectionChangesPublisher(),
            getToolListItemInterfaceStringsRepository
                .getStringsPublisher(translateInLanguage: translatedInAppLanguage)
                .setFailureType(to: Error.self)
        )
        .flatMap({ (resourcesChanged: Void, interfaceStrings: ToolListItemInterfaceStringsDomainModel) -> AnyPublisher<[SpotlightToolListItemDomainModel], Never> in
        
            let spotlightToolResources: [ResourceDataModel] = self.resourcesRepository.getSpotlightTools(sortByDefaultOrder: true)

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
