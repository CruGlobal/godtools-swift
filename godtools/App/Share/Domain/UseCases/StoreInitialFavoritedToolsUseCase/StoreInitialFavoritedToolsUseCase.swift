//
//  StoreInitialFavoritedToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreInitialFavoritedToolsUseCase {
    
    private let resourcesRepository: ResourcesRepository
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let launchCountRepository: LaunchCountRepository
    
    private var cancellables = Set<AnyCancellable>()
    
    init(resourcesRepository: ResourcesRepository, favoritedResourcesRepository: FavoritedResourcesRepository, launchCountRepository: LaunchCountRepository) {
        
        self.resourcesRepository = resourcesRepository
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.launchCountRepository = launchCountRepository
        
        Publishers.Zip(resourcesRepository.getResourcesChanged(), launchCountRepository.getLaunchCountPublisher())
            .sink { (resourcesChanged: Void, launchCount: Int) in
                
                guard favoritedResourcesRepository.numberOfFavoritedResources == 0 && launchCount == 1 else {
                    return
                }
                
                _ = favoritedResourcesRepository.storeFavoritedResource(resourceId: "2")
                _ = favoritedResourcesRepository.storeFavoritedResource(resourceId: "1")
                _ = favoritedResourcesRepository.storeFavoritedResource(resourceId: "4")
                _ = favoritedResourcesRepository.storeFavoritedResource(resourceId: "8")
            }
            .store(in: &cancellables)
    }
}
