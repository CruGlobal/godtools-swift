//
//  ShareablesDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ShareablesDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getShareableImageRepositoryInterface() -> GetShareableImageRepositoryInterface {
        return GetShareableImageRepository(
            resourcesFileCache: coreDataLayer.getResourcesFileCache()
        )
    }
    
    func getShareablesRepositoryInterface() -> GetShareablesRepositoryInterface {
        return GetShareablesRepository(
            translationsRepository: coreDataLayer.getTranslationsRepository()
        )
    }
}
