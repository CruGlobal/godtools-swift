//
//  GetDownloadToolProgressInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetDownloadToolProgressInterfaceStringsRepository: GetDownloadToolProgressInterfaceStringsRepositoryInterface {
    
    private let resourcesRepository: ResourcesRepository
    private let localizationServices: LocalizationServices
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(resourcesRepository: ResourcesRepository, localizationServices: LocalizationServices, favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.localizationServices = localizationServices
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func getStringsPublisher(toolId: String?, translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<DownloadToolProgressInterfaceStringsDomainModel, Never> {
                        
        let localeId: String = translateInAppLanguage
        
        let toolIsFavorited: Bool?
        
        if let toolId = toolId, let resource = resourcesRepository.getResource(id: toolId), (resource.resourceTypeEnum == .article || resource.resourceTypeEnum == .tract) {
            
            toolIsFavorited = favoritedResourcesRepository.getResourceIsFavorited(id: toolId)
        }
        else {
            toolIsFavorited = false
        }
        
        let interfaceStrings = DownloadToolProgressInterfaceStringsDomainModel(
            toolIsFavorited: toolIsFavorited,
            downloadingToolMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "loading_favorited_tool"),
            favoriteThisToolForOfflineUseMessage: localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "loading_unfavorited_tool")
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
