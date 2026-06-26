//
//  GetSpotlightToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetSpotlightToolsUseCase {
        
    private let resourcesRepository: ResourcesRepository
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let languagesRepository: LanguagesRepository
    private let getTranslatedToolName: GetTranslatedToolName
    private let getTranslatedToolCategory: GetTranslatedToolCategory
    private let getToolListItemStrings: GetToolListItemStrings
    private let getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    
    init(
        resourcesRepository: ResourcesRepository,
        favoritedResourcesRepository: FavoritedResourcesRepository,
        languagesRepository: LanguagesRepository,
        getTranslatedToolName: GetTranslatedToolName,
        getTranslatedToolCategory: GetTranslatedToolCategory,
        getToolListItemStrings: GetToolListItemStrings,
        getTranslatedToolLanguageAvailability: GetTranslatedToolLanguageAvailability
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.languagesRepository = languagesRepository
        self.getTranslatedToolName = getTranslatedToolName
        self.getTranslatedToolCategory = getTranslatedToolCategory
        self.getToolListItemStrings = getToolListItemStrings
        self.getTranslatedToolLanguageAvailability = getTranslatedToolLanguageAvailability
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel, languageIdForAvailabilityText: String?) -> AnyPublisher<[SpotlightToolListItemDomainModel], Error> {
        
        let languageForAvailabilityTextModel: LanguageDataModel? = getLanguage(id: languageIdForAvailabilityText)
        
        let strings: ToolListItemStringsDomainModel = getToolListItemStrings.getStrings(appLanguage: appLanguage)
        
        return resourcesRepository
            .observeCollectionChangesPublisher()
            .receive(on: DispatchQueue.global())
            .flatMap({ (resourcesChanged: Void) -> AnyPublisher<[SpotlightToolListItemDomainModel], Never> in
            
                let spotlightToolResources: [ResourceDataModel] = self.resourcesRepository.getSpotlightTools(sortByDefaultOrder: true)
                
                let spotlightTools: [SpotlightToolListItemDomainModel] = spotlightToolResources
                    .map({
                        
                        let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel
                        
                        if let language = languageForAvailabilityTextModel {
                            
                            toolLanguageAvailability = self.getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(resource: $0, language: language, translateInLanguage: appLanguage)
                        }
                        else {
                            toolLanguageAvailability = ToolLanguageAvailabilityDomainModel(availabilityString: "", isAvailable: false)
                        }
                        
                        return SpotlightToolListItemDomainModel(
                            strings: strings,
                            analyticsToolAbbreviation: $0.abbreviation,
                            dataModelId: $0.id,
                            bannerImageId: $0.attrBanner,
                            name: self.getTranslatedToolName.getToolName(resource: $0, translateInLanguage: appLanguage),
                            category: self.getTranslatedToolCategory.getTranslatedCategory(resource: $0, translateInLanguage: appLanguage),
                            isFavorited: self.favoritedResourcesRepository.getResourceIsFavorited(id: $0.id),
                            languageAvailability: toolLanguageAvailability
                        )
                    })
                
                return Just(spotlightTools)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func getLanguage(id: String?) -> LanguageDataModel? {
        
        guard let id = id else {
            return nil
        }
        
        return languagesRepository.getLanguageById(id: id)
    }
}
