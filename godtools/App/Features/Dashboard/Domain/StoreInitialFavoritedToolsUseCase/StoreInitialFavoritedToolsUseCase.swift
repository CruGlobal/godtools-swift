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
        
        Publishers.Zip(
            resourcesRepository.getResourcesChanged(),
            launchCountRepository.getLaunchCountPublisher()
        )
        .flatMap({ (resourcesChanged: Void, launchCount: Int) -> AnyPublisher<[FavoritedResourceDataModel], Error> in
            
            guard favoritedResourcesRepository.getNumberOfFavoritedResources() == 0 && launchCount == 1 else {
                return Just([]).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            
            let favoritedResourceIdsToStore: [String] = ["2", "1", "4", "8"]
            
            return self.favoritedResourcesRepository.storeFavoritedResourcesPublisher(ids: favoritedResourceIdsToStore)
                .eraseToAnyPublisher()
            
        })
        .sink { _ in
            
        } receiveValue: { _ in
            
        }
        .store(in: &cancellables)
    }
}
