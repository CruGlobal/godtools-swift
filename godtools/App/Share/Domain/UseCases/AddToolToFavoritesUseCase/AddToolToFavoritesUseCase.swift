//
//  AddToolToFavoritesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AddToolToFavoritesUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let getFavoritedResourcesLatestTranslationFilesUseCase: GetFavoritedResourcesLatestTranslationFilesUseCase
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository, getFavoritedResourcesLatestTranslationFilesUseCase: GetFavoritedResourcesLatestTranslationFilesUseCase) {
     
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.getFavoritedResourcesLatestTranslationFilesUseCase = getFavoritedResourcesLatestTranslationFilesUseCase
    }
    
    func addToolToFavorites(resourceId: String) {
        
        switch favoritedResourcesRepository.storeFavoritedResource(resourceId: resourceId) {
        case .success(let favoritedResource):
            getFavoritedResourcesLatestTranslationFilesUseCase.getLatestTranslationFiles(for: [favoritedResource])
        case .failure( _):
            break
        }
    }
}
