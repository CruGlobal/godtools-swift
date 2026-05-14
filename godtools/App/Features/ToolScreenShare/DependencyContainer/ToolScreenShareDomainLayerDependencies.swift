//
//  ToolScreenShareDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ToolScreenShareDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let coreDomainLayer: AppDomainLayerDependencies
    private let dataLayer: ToolScreenShareDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies, dataLayer: ToolScreenShareDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.coreDomainLayer = coreDomainLayer
        self.dataLayer = dataLayer
    }
    
    func getDidViewToolScreenShareTutorialUseCase() -> DidViewToolScreenShareTutorialUseCase {
        return DidViewToolScreenShareTutorialUseCase(
            tutorialViewsRepository: dataLayer.getToolScreenShareTutorialViewsRepository()
        )
    }
    
    func getCreatingToolScreenShareSessionStringsUseCase() -> GetCreatingToolScreenShareSessionStringsUseCase {
        return GetCreatingToolScreenShareSessionStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getCreatingToolScreenShareSessionTimedOutStringsUseCase() -> GetCreatingToolScreenShareSessionTimedOutStringsUseCase {
        return GetCreatingToolScreenShareSessionTimedOutStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getShareToolScreenShareSessionStringsUseCase() -> GetShareToolScreenShareSessionStringsUseCase {
        return GetShareToolScreenShareSessionStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolScreenShareTutorialHasBeenViewedUseCase() -> GetToolScreenShareTutorialHasBeenViewedUseCase {
        return GetToolScreenShareTutorialHasBeenViewedUseCase(
            tutorialViewsRepository: dataLayer.getToolScreenShareTutorialViewsRepository()
        )
    }
    
    func getToolScreenShareTutorialStringsUseCase() -> GetToolScreenShareTutorialStringsUseCase {
        return GetToolScreenShareTutorialStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolScreenShareTutorialUseCase() -> GetToolScreenShareTutorialUseCase {
        return GetToolScreenShareTutorialUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
