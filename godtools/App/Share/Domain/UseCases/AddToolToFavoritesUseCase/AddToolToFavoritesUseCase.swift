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
    private let getFavoritedToolsLatestTranslationFilesUseCase: GetFavoritedToolsLatestTranslationFilesUseCase
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository, getFavoritedToolsLatestTranslationFilesUseCase: GetFavoritedToolsLatestTranslationFilesUseCase) {
     
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.getFavoritedToolsLatestTranslationFilesUseCase = getFavoritedToolsLatestTranslationFilesUseCase
    }
    
    func addToolToFavorites(resourceId: String) {
        
        switch favoritedResourcesRepository.storeFavoritedResource(resourceId: resourceId) {
        case .success(let favoritedTool):
            getFavoritedToolsLatestTranslationFilesUseCase.getLatestTranslationFiles(for: [favoritedTool])
        case .failure( _):
            break
        }
    }
}
