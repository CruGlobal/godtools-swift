//
//  StoreInitialFavoritedToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

final class StoreInitialFavoritedToolsUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func execute() async throws {
        
        let favoritedResourceCount: Int = try favoritedResourcesRepository.getObjectCount()
        
        guard favoritedResourceCount == 0 else {
            return
        }
        
        let favoritedResourceIdsToStore: [String] = ["2", "1", "4", "8"].reversed()
        
        _ = try await favoritedResourcesRepository
            .storeFavoritedResources(ids: favoritedResourceIdsToStore)
    }
}
