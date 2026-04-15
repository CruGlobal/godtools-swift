//
//  ToolScreenShareQRCodeFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 6/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class ToolScreenShareQRCodeFeatureDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let coreDomainLayer: AppDomainLayerDependencies
    private let dataLayer: ToolScreenShareQRCodeFeatureDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies, dataLayer: ToolScreenShareQRCodeFeatureDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.coreDomainLayer = coreDomainLayer
        self.dataLayer = dataLayer
    }
    
    func getToolScreenShareQRCodeStringsUseCase() -> GetToolScreenShareQRCodeStringsUseCase {
        return GetToolScreenShareQRCodeStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
