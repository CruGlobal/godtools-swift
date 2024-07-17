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
    
    private func getToolScreenShareTutorialViewsRepository() -> ToolScreenShareTutorialViewsRepository {
        return ToolScreenShareTutorialViewsRepository(
            cache: RealmToolScreenShareTutorialViewsCache(
                realmDatabase: coreDataLayer.getSharedRealmDatabase()
            )
        )
    }
    
    func getTractRemoteSharePublisher() -> TractRemoteSharePublisher {
        
        let webSocket: WebSocketType = StarscreamWebSocket()
        
        let loggingEnabled: Bool = coreDataLayer.getAppBuild().isDebug
        
        return TractRemoteSharePublisher(
            config: coreDataLayer.getAppConfig(),
            webSocket: webSocket,
            webSocketChannelPublisher: ActionCableChannelPublisher(webSocket: webSocket, loggingEnabled: loggingEnabled),
            loggingEnabled: loggingEnabled
        )
    }
    
    func  getTractRemoteShareSubscriber() -> TractRemoteShareSubscriber {
        
        let webSocket: WebSocketType = StarscreamWebSocket()
        
        let loggingEnabled: Bool = coreDataLayer.getAppBuild().isDebug
        
        return TractRemoteShareSubscriber(
            config: coreDataLayer.getAppConfig(),
            webSocket: webSocket,
            webSocketChannelSubscriber: ActionCableChannelSubscriber(webSocket: webSocket, loggingEnabled: loggingEnabled),
            loggingEnabled: loggingEnabled
        )
    }
    
    func getTractRemoteShareURLBuilder() -> TractRemoteShareURLBuilder {
        return TractRemoteShareURLBuilder(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository()
        )
    }
    
    // MARK: - Domain Interface
    
    func getCreatingToolScreenShareSessionInterfaceStringsRepositoryInterface() -> GetCreatingToolScreenShareSessionInterfaceStringsRepositoryInterface {
        return GetCreatingToolScreenShareSessionInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getCreatingToolScreenShareSessionTimedOutInterfaceStringsRepositoryInterface() -> GetCreatingToolScreenShareSessionTimedOutInterfaceStringsRepositoryInterface {
        return GetCreatingToolScreenShareSessionTimedOutInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getShareToolScreenShareSessionInterfaceStringsRepositoryInterface() -> GetShareToolScreenShareSessionInterfaceStringsRepositoryInterface {
        return GetShareToolScreenShareSessionInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
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
    
    func getToolScreenShareTutorialViewedRepositoryInterface() -> GetToolScreenShareTutorialViewedRepositoryInterface {
        return GetToolScreenShareTutorialViewedRepository(
            tutorialViewsRepository: getToolScreenShareTutorialViewsRepository()
        )
    }
    
    func getIncrementNumberOfToolScreenShareTutorialViewsRepositoryInterface() -> IncrementNumberOfToolScreenShareTutorialViewsRepositoryInterface {
        return IncrementNumberOfToolScreenShareTutorialViewsRepository(
            tutorialViewsRepository: getToolScreenShareTutorialViewsRepository()
        )
    }
}
