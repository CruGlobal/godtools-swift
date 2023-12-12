//
//  ToggleToolFavoritedUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class ToggleToolFavoritedUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let addToolToFavoritesUseCase: AddToolToFavoritesUseCase
    private let removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository, addToolToFavoritesUseCase: AddToolToFavoritesUseCase, removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.addToolToFavoritesUseCase = addToolToFavoritesUseCase
        self.removeToolFromFavoritesUseCase = removeToolFromFavoritesUseCase
    }
    
    func toggleToolFavoritedPublisher(id: String) -> AnyPublisher<Bool, Never> {
                        
        return favoritedResourcesRepository.getResourceIsFavoritedPublisher(id: id)
            .flatMap({ (isFavorited: Bool) -> AnyPublisher<Bool, Never> in
                
                if isFavorited {
                    
                    return self.removeToolFromFavoritesUseCase.removeToolFromFavoritesPublisher(id: id)
                        .map {
                            return false
                        }
                        .eraseToAnyPublisher()
                }
                else {
                    
                    return self.addToolToFavoritesUseCase.addToolToFavoritesPublisher(id: id)
                        .map {
                            return true
                        }
                        .eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }
}
