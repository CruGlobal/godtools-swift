//
//  GetToolsInterfaceStringsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

class ToolsDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: ToolsDataLayerDependencies
    private let coreDomainLayer: AppDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: ToolsDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
        self.coreDomainLayer = coreDomainLayer
    }
    
    func getPullToRefreshToolsUseCase() -> PullToRefreshToolsUseCase {
        return PullToRefreshToolsUseCase(
            resourcesRepository: coreDataLayer.getResourcesRepository()
        )
    }
    
    func getToolsStringsUseCase() -> GetToolsStringsUseCase {
        return GetToolsStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getAllToolsUseCase() -> GetAllToolsUseCase {
        return GetAllToolsUseCase(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            getToolsListItems: coreDomainLayer.supporting.getToolsListItems()
        )
    }
}
