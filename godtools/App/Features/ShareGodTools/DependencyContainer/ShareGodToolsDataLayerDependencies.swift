//
//  ShareGodToolsDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class ShareGodToolsDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer
    
    // MARK: - Domain Interface
    
    func getShareGodToolsInterfaceStringsRepository() -> GetShareGodToolsInterfaceStringsRepositoryInterface {
        return GetShareGodToolsInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
