//
//  ToolScreenShareQRCodeDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 6/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class ToolScreenShareQRCodeDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let coreDomainLayer: AppDomainLayerDependencies
    private let dataLayer: ToolScreenShareQRCodeDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies, dataLayer: ToolScreenShareQRCodeDataLayerDependencies) {
        
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
