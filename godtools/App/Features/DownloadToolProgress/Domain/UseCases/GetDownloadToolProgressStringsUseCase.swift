//
//  GetDownloadToolProgressStringsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class GetDownloadToolProgressStringsUseCase: Sendable {
    
    private let resourcesRepository: ResourcesRepository
    private let localizationServices: LocalizationServicesInterface
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(
        resourcesRepository: ResourcesRepository,
        localizationServices: LocalizationServicesInterface,
        favoritedResourcesRepository: FavoritedResourcesRepository
    ) {
        
        self.resourcesRepository = resourcesRepository
        self.localizationServices = localizationServices
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func execute(toolId: String?, appLanguage: AppLanguageDomainModel) -> DownloadToolProgressStringsDomainModel {

        let resource: ResourceDataModel?
        
        if let toolId = toolId, let resourceModel = resourcesRepository.getResourceById(id: toolId) {
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
        
        let downloadMessageKey: String

        if toolCanBeFavorited && !toolIsFavorited {
            downloadMessageKey = LocalizableStringKeys.loadingUnfavoritedTool.key
        }
        else {
            downloadMessageKey = LocalizableStringKeys.loadingFavoritedTool.key
        }

        let strings: [String: String] = localizationServices.stringsForKeys(
            keys: [
                downloadMessageKey
            ],
            fetchOrder: LocalizationServicesDefaults.getFetchOrder(localeIdentifier: appLanguage),
            shouldFallbackToKey: LocalizationServicesDefaults.fallbackToKey
        )

        return DownloadToolProgressStringsDomainModel(
            downloadMessage: strings[downloadMessageKey] ?? ""
        )
    }
}
