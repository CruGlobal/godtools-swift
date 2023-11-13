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
    
    private let localizationServices: LocalizationServices
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(localizationServices: LocalizationServices, favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.localizationServices = localizationServices
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func getStringsPublisher(resource: ResourceModel?, translateInAppLanguageCode: AppLanguageCodeDomainModel) -> AnyPublisher<DownloadToolProgressInterfaceStringsDomainModel, Never> {
                        
        let localeId: String = translateInAppLanguageCode
        let toolIsFavorited: Bool?
        
        let resourceType: ResourceType? = resource?.resourceTypeEnum
        
        if resourceType == .article || resourceType == .tract, let resourceId = resource?.id {

            toolIsFavorited = favoritedResourcesRepository.getResourceIsFavorited(id: resourceId)
        }
        else {
            
            toolIsFavorited = nil
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
