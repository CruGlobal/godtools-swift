//
//  ToolScreenShareFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolScreenShareFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    private func getToolScreenShareViewsRepository() -> ToolScreenShareViewsRepository {
        return ToolScreenShareViewsRepository(
            cache: RealmToolScreenShareViewsCache(
                realmDatabase: coreDataLayer.getSharedRealmDatabase()
            )
        )
    }
    
    // MARK: - Domain Interface
    
    func getToolScreenShareTutorialInterfaceStringsRepositoryInterface() -> GetToolScreenShareTutorialInterfaceStringsRepositoryInterface {
        return GetToolScreenShareTutorialInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolScreenShareTutorialRepositoryInterface() -> GetToolScreenShareTutorialRepositoryInterface {
        return GetToolScreenShareTutorialRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getToolScreenShareViewedRepositoryInterface() -> GetToolScreenShareViewedRepositoryInterface {
        return GetToolScreenShareViewedRepository(
            toolScreenShareViewsRepository: getToolScreenShareViewsRepository()
        )
    }
    
    func getIncrementNumberOfToolScreenShareViewsRepositoryInterface() -> IncrementNumberOfToolScreenShareViewsRepositoryInterface {
        return IncrementNumberOfToolScreenShareViewsRepository(
            toolScreenShareViewsRepository: getToolScreenShareViewsRepository()
        )
    }
}
