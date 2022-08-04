//
//  GetAllFavoritedResourcesLatestTranslationFilesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/3/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetAllFavoritedResourcesLatestTranslationFilesUseCase {
    
    private let getAllFavoritedResourcesUseCase: GetAllFavoritedResourcesUseCase
    private let getFavoritedResourcesLatestTranslationFilesUseCase: GetFavoritedResourcesLatestTranslationFilesUseCase
    
    init(getAllFavoritedResourcesUseCase: GetAllFavoritedResourcesUseCase, getFavoritedResourcesLatestTranslationFilesUseCase: GetFavoritedResourcesLatestTranslationFilesUseCase) {
        
        self.getAllFavoritedResourcesUseCase = getAllFavoritedResourcesUseCase
        self.getFavoritedResourcesLatestTranslationFilesUseCase = getFavoritedResourcesLatestTranslationFilesUseCase
    }
    
    func getLatestTranslationFilesForAllFavoritedResources() {
        
        let allFavoritedResources: [FavoritedResourceModel] = getAllFavoritedResourcesUseCase.getAllFavoritedResources()
        
        getFavoritedResourcesLatestTranslationFilesUseCase.getLatestTranslationFiles(for: allFavoritedResources)
    }
}
