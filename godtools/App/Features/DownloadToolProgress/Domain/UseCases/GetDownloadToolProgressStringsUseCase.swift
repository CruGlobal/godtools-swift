//
//  GetDownloadToolProgressStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetDownloadToolProgressStringsUseCase {
    
    private let resourcesRepository: ResourcesRepository
    private let localizationServices: LocalizationServicesInterface
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(resourcesRepository: ResourcesRepository, localizationServices: LocalizationServicesInterface, favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.localizationServices = localizationServices
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func execute(toolId: String?, appLanguage: AppLanguageDomainModel) -> AnyPublisher<DownloadToolProgressStringsDomainModel, Never> {
                        
        let localeId: String = appLanguage
        
        let resource: ResourceDataModel?
        
        if let toolId = toolId, let resourceModel = resourcesRepository.persistence.getDataModelNonThrowing(id: toolId) {
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
            downloadMessage = localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "loading_unfavorited_tool")
        }
        else {
            downloadMessage = localizationServices.stringForLocaleElseEnglish(localeIdentifier: localeId, key: "loading_favorited_tool")
        }
        
        let strings = DownloadToolProgressStringsDomainModel(
            downloadMessage: downloadMessage
        )
        
        return Just(strings)
            .eraseToAnyPublisher()
    }
}
