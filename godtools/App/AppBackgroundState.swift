//
//  AppBackgroundState.swift
//  godtools
//
//  Created by Levi Eggert on 8/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AppBackgroundState {
    
    static let shared: AppBackgroundState = AppBackgroundState()
    
    private var getAllFavoritedToolsLatestTranslationFilesUseCase: GetAllFavoritedToolsLatestTranslationFilesUseCase?
    private var storeInitialFavoritedToolsUseCase: StoreInitialFavoritedToolsUseCase?
    private var isStarted: Bool = false
    
    private init() {
        
    }
    
    func start(getAllFavoritedToolsLatestTranslationFilesUseCase: GetAllFavoritedToolsLatestTranslationFilesUseCase, storeInitialFavoritedToolsUseCase: StoreInitialFavoritedToolsUseCase) {
        
        guard !isStarted else {
            return
        }
        
        let environment: [String: String] = ProcessInfo().environment
        
        isStarted = true
        
        self.getAllFavoritedToolsLatestTranslationFilesUseCase = getAllFavoritedToolsLatestTranslationFilesUseCase
        self.storeInitialFavoritedToolsUseCase = storeInitialFavoritedToolsUseCase
    }
}
