//
//  ToolScreenShareFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolScreenShareFeatureDomainLayerDependencies {
    
    private let dataLayer: ToolScreenShareFeatureDataLayerDependencies
    
    init(dataLayer: ToolScreenShareFeatureDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getToolScreenShareTutorialUseCase() -> GetToolScreenShareTutorialUseCase {
        return GetToolScreenShareTutorialUseCase(
            getInterfaceStringsRepositoryInterface: dataLayer.getToolScreenShareTutorialInterfaceStringsRepositoryInterface(),
            getTutorialRepositoryInterface: dataLayer.getToolScreenShareTutorialRepositoryInterface()
        )
    }
}
