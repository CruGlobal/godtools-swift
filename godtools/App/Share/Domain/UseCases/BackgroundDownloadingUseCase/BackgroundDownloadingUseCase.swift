//
//  BackgroundDownloadingUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/4/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class BackgroundDownloadingUseCase {
        
    private let getAllFavoritedToolsLatestTranslationFilesUseCase: GetAllFavoritedToolsLatestTranslationFilesUseCase
    private let storeInitialFavoritedToolsUseCase: StoreInitialFavoritedToolsUseCase
    
    init(getAllFavoritedToolsLatestTranslationFilesUseCase: GetAllFavoritedToolsLatestTranslationFilesUseCase, storeInitialFavoritedToolsUseCase: StoreInitialFavoritedToolsUseCase) {
        
        self.getAllFavoritedToolsLatestTranslationFilesUseCase = getAllFavoritedToolsLatestTranslationFilesUseCase
        self.storeInitialFavoritedToolsUseCase = storeInitialFavoritedToolsUseCase
    }
}
