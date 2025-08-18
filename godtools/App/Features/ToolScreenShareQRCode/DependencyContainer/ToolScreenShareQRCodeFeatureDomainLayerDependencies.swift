//
//  ToolScreenShareQRCodeFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 6/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class ToolScreenShareQRCodeFeatureDomainLayerDependencies {
    
    private let dataLayer: ToolScreenShareQRCodeFeatureDataLayerDependencies
    
    init(dataLayer: ToolScreenShareQRCodeFeatureDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getViewToolScreenShareQRCodeUseCase() -> ViewToolScreenShareQRCodeUseCase {
        return ViewToolScreenShareQRCodeUseCase(
            getInterfaceStringsRepositoryInterface: dataLayer.getToolScreenShareQRCodeInterfaceStringsRepositoryInterface()
        )
    }
}
