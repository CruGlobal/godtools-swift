//
//  GetSpotlightToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetSpotlightToolsUseCase: Sendable {
        
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
    
    @MainActor func execute(
        appLanguage: AppLanguageDomainModel,
        languageIdForAvailabilityText: String?
    ) -> AnyPublisher<[SpotlightToolListItemDomainModel], Error> {
        
        return resourcesRepository
            .observeCollectionChangesPublisher()
            .receive(on: DispatchQueue.global())
            .flatMap({ (resourcesChanged: Void) -> AnyPublisher<[SpotlightToolListItemDomainModel], Never> in

                return AnyPublisher() {
                    return await self.asyncExecute(
                        appLanguage: appLanguage,
                        languageIdForAvailabilityText: languageIdForAvailabilityText
                    )
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func asyncExecute(
        appLanguage: AppLanguageDomainModel,
        languageIdForAvailabilityText: String?
    ) async -> [SpotlightToolListItemDomainModel] {
        
        let languageForAvailabilityTextModel: LanguageDataModel? = getLanguage(id: languageIdForAvailabilityText)
        
        let strings: ToolListItemStringsDomainModel = getToolListItemStrings.getStrings(appLanguage: appLanguage)

        let spotlightToolResources: [ResourceDataModel] = resourcesRepository.getSpotlightTools(
            sortByDefaultOrder: true
        )

        var spotlightTools: [SpotlightToolListItemDomainModel] = Array()

        for resource in spotlightToolResources {

            let toolLanguageAvailability: ToolLanguageAvailabilityDomainModel

            if let language = languageForAvailabilityTextModel {

                toolLanguageAvailability = await getTranslatedToolLanguageAvailability.getTranslatedLanguageAvailability(
                    resource: resource,
                    language: language,
                    translateInLanguage: appLanguage
                )
            }
            else {
                
                toolLanguageAvailability = ToolLanguageAvailabilityDomainModel(
                    availabilityString: "",
                    isAvailable: false
                )
            }

            spotlightTools.append(
                SpotlightToolListItemDomainModel(
                    strings: strings,
                    analyticsToolAbbreviation: resource.abbreviation,
                    dataModelId: resource.id,
                    bannerImageId: resource.attrBanner,
                    name: getTranslatedToolName.getToolName(resource: resource, translateInLanguage: appLanguage),
                    category: await getTranslatedToolCategory.getTranslatedCategory(resource: resource, translateInLanguage: appLanguage),
                    isFavorited: favoritedResourcesRepository.getResourceIsFavorited(id: resource.id),
                    languageAvailability: toolLanguageAvailability
                )
            )
        }

        return spotlightTools
    }
    
    private func getLanguage(id: String?) -> LanguageDataModel? {
        
        guard let id = id else {
            return nil
        }
        
        return languagesRepository.getLanguageById(id: id)
    }
}
