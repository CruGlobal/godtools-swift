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
            tutorialViewedRepositoryInterface: dataLayer.getToolScreenShareTutorialViewedRepositoryInterface()
        )
    }
    
    func getDidViewToolScreenShareTutorialUseCase() -> DidViewToolScreenShareTutorialUseCase {
        return DidViewToolScreenShareTutorialUseCase(
            incrementNumberOfViewsRepositoryInterface: dataLayer.getIncrementNumberOfToolScreenShareTutorialViewsRepositoryInterface()
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
    
    func getViewShareToolScreenShareSessionUseCase() -> ViewShareToolScreenShareSessionUseCase {
        return ViewShareToolScreenShareSessionUseCase(
            getInterfaceStringsRepositoryInterface: dataLayer.getShareToolScreenShareSessionInterfaceStringsRepositoryInterface()
        )
    }
    
    func getViewToolScreenShareTutorialUseCase() -> ViewToolScreenShareTutorialUseCase {
        return ViewToolScreenShareTutorialUseCase(
            getInterfaceStringsRepositoryInterface: dataLayer.getToolScreenShareTutorialInterfaceStringsRepositoryInterface(),
            getTutorialRepositoryInterface: dataLayer.getToolScreenShareTutorialRepositoryInterface()
        )
    }
}
