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
    
    func getToolScreenShareTutorialHasBeenViewedUseCase() -> GetToolScreenShareTutorialHasBeenViewedUseCase {
        return GetToolScreenShareTutorialHasBeenViewedUseCase(
            getToolScreenShareViewedRepositoryInterface: dataLayer.getToolScreenShareViewedRepositoryInterface()
        )
    }
    
    func getDidViewToolScreenShareUseCase() -> DidViewToolScreenShareUseCase {
        return DidViewToolScreenShareUseCase(
            incrementNumberOfToolScreenShareViewsRepositoryInterface: dataLayer.getIncrementNumberOfToolScreenShareViewsRepositoryInterface()
        )
    }
    
    func getViewCreatingToolScreenShareSessionTimedOutUseCase() -> ViewCreatingToolScreenShareSessionTimedOutUseCase {
        return ViewCreatingToolScreenShareSessionTimedOutUseCase(
            getInterfaceStringsRepositoryInterface: dataLayer.getCreatingToolScreenShareSessionTimedOutInterfaceStringsRepositoryInterface()
        )
    }
    
    func getViewCreatingToolScreenShareSessionUseCase() -> ViewCreatingToolScreenShareSessionUseCase {
        return ViewCreatingToolScreenShareSessionUseCase(
            getInterfaceStringsRepositoryInterface: dataLayer.getCreatingToolScreenShareSessionInterfaceStringsRepositoryInterface()
        )
    }
    
    func getViewToolScreenShareTutorialUseCase() -> ViewToolScreenShareTutorialUseCase {
        return ViewToolScreenShareTutorialUseCase(
            getInterfaceStringsRepositoryInterface: dataLayer.getToolScreenShareTutorialInterfaceStringsRepositoryInterface(),
            getTutorialRepositoryInterface: dataLayer.getToolScreenShareTutorialRepositoryInterface()
        )
    }
}
