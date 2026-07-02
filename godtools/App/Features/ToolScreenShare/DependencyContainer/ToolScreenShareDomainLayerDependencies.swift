//
//  ToolScreenShareDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ToolScreenShareDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: ToolScreenShareDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: ToolScreenShareDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getDidViewToolScreenShareTutorialUseCase() -> DidViewToolScreenShareTutorialUseCase {
        return DidViewToolScreenShareTutorialUseCase(
            tutorialViewsRepository: dataLayer.getToolScreenShareTutorialViewsRepository()
        )
    }
    
    func getCreatingToolScreenShareSessionStringsUseCase() -> GetCreatingToolScreenShareSessionStringsUseCase {
        return GetCreatingToolScreenShareSessionStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getCreatingToolScreenShareSessionTimedOutStringsUseCase() -> GetCreatingToolScreenShareSessionTimedOutStringsUseCase {
        return GetCreatingToolScreenShareSessionTimedOutStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getShareToolScreenShareSessionStringsUseCase() -> GetShareToolScreenShareSessionStringsUseCase {
        return GetShareToolScreenShareSessionStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getToolScreenShareTutorialHasBeenViewedUseCase() -> GetToolScreenShareTutorialHasBeenViewedUseCase {
        return GetToolScreenShareTutorialHasBeenViewedUseCase(
            tutorialViewsRepository: dataLayer.getToolScreenShareTutorialViewsRepository()
        )
    }
    
    func getToolScreenShareTutorialStringsUseCase() -> GetToolScreenShareTutorialStringsUseCase {
        return GetToolScreenShareTutorialStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getToolScreenShareTutorialUseCase() -> GetToolScreenShareTutorialUseCase {
        return GetToolScreenShareTutorialUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
}
