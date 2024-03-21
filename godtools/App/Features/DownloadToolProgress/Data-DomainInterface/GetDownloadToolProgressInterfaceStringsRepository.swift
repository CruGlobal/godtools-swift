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
    private let localizationServices: LocalizationServicesInterface
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(resourcesRepository: ResourcesRepository, localizationServices: LocalizationServicesInterface, favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.localizationServices = localizationServices
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func getStringsPublisher(toolId: String?, translateInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<DownloadToolProgressInterfaceStringsDomainModel, Never> {
                        
        let localeId: String = translateInAppLanguage
        let stringsFileType: LocalizableStringsFileType = .strings
        
        let resource: ResourceModel?
        
        if let toolId = toolId, let resourceModel = resourcesRepository.getResource(id: toolId) {
            resource = resourceModel
        }
        else {
            resource = nil
        }
        
        let toolCanBeFavorited: Bool = (resource?.resourceTypeEnum == .article || resource?.resourceTypeEnum == .tract || resource?.resourceTypeEnum == .chooseYourOwnAdventure)
        let toolIsFavorited: Bool
        
        if let resource = resource {
            toolIsFavorited = favoritedResourcesRepository.getResourceIsFavorited(id: resource.id)
        }
        else {
            toolIsFavorited = false
        }
        
        let downloadMessage: String
        
        if toolCanBeFavorited && !toolIsFavorited {
            downloadMessage = localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "loading_unfavorited_tool", fileType: stringsFileType)
        }
        else {
            downloadMessage = localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "loading_favorited_tool", fileType: stringsFileType)
        }
        
        let interfaceStrings = DownloadToolProgressInterfaceStringsDomainModel(
            downloadMessage:  downloadMessage
        )
        
        return Just(interfaceStrings)
            .eraseToAnyPublisher()
    }
}
