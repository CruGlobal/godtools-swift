//
//  GetAllFavoritedToolsLatestTranslationFilesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/3/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetAllFavoritedToolsLatestTranslationFilesUseCase {
    
    private let getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase
    private let getFavoritedToolsLatestTranslationFilesUseCase: GetFavoritedToolsLatestTranslationFilesUseCase
    
    init(getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getFavoritedToolsLatestTranslationFilesUseCase: GetFavoritedToolsLatestTranslationFilesUseCase) {
        
        self.getAllFavoritedToolsUseCase = getAllFavoritedToolsUseCase
        self.getFavoritedToolsLatestTranslationFilesUseCase = getFavoritedToolsLatestTranslationFilesUseCase
    }
    
    func getLatestTranslationFilesForAllFavoritedTools() {
        
        let allFavoritedTools: [FavoritedResourceModel] = getAllFavoritedToolsUseCase.getAllFavoritedTools()
        
        getFavoritedToolsLatestTranslationFilesUseCase.getLatestTranslationFiles(for: allFavoritedTools)
    }
}
