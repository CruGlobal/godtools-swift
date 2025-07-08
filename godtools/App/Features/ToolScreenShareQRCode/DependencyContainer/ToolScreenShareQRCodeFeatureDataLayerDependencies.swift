//
//  ToolScreenShareQRCodeFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 6/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class ToolScreenShareQRCodeFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getToolScreenShareQRCodeInterfaceStringsRepositoryInterface() -> GetToolScreenShareQRCodeInterfaceStringsRepositoryInterface {
        return GetToolScreenShareQRCodeInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
