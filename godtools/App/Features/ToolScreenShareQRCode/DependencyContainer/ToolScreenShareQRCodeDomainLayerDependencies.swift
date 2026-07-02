//
//  ToolScreenShareQRCodeDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 6/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class ToolScreenShareQRCodeDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: ToolScreenShareQRCodeDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: ToolScreenShareQRCodeDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getToolScreenShareQRCodeStringsUseCase() -> GetToolScreenShareQRCodeStringsUseCase {
        return GetToolScreenShareQRCodeStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
}
