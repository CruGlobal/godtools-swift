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
                
        let downloadMessageLocalizedKey: String
        let downloadMessage: String
        
        let resourceType: ResourceType? = resource?.resourceTypeEnum
        
        if resourceType == .article || resourceType == .tract, let resourceId = resource?.id {

            let isFavoritedResource: Bool = favoritedResourcesRepository.getResourceIsFavorited(id: resourceId)
            
            downloadMessageLocalizedKey = isFavoritedResource ? "loading_favorited_tool" : "loading_unfavorited_tool"
        }
        else if resourceType == .lesson {
            
            downloadMessageLocalizedKey = "loading_favorited_tool"
        }
        else {
            
            downloadMessageLocalizedKey = "loading_favorited_tool"
        }
        
        downloadMessage = localizationServices.stringForLocaleElseEnglish(localeIdentifier: translateInAppLanguageCode, key: downloadMessageLocalizedKey)
        
        let interfaceStrings = DownloadToolProgressInterfaceStringsDomainModel(
            downloadMessage: downloadMessage
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
