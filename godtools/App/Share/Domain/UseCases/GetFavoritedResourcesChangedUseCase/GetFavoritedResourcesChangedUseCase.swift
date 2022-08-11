//
//  GetFavoritedResourcesChangedUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetFavoritedResourcesChangedUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
     
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func getFavoritedResourcesChanged() -> AnyPublisher<Void, Never> {
        
        return favoritedResourcesRepository.getFavoritedResourcesChanged()
    }
}
