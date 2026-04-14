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
        
    func getToolScreenShareTutorialViewsRepository() -> ToolScreenShareTutorialViewsRepository {
        return ToolScreenShareTutorialViewsRepository(
            cache: RealmToolScreenShareTutorialViewsCache(
                realmDatabase: coreDataLayer.getSharedLegacyRealmDatabase()
            )
        )
    }
    
    private func getNewWebSocketForScreenShare() -> WebSocketInterface {
        
        // TODO: Shouldn't force unwrap url here. ~Levi
        let url: URL = URL(string: coreDataLayer.getAppConfig().getTractRemoteShareConnectionUrl())!
        
        return coreDataLayer.getWebSocket(url: url)
    }
    
    func getTractRemoteSharePublisher() -> TractRemoteSharePublisher {
        
        let webSocket: WebSocketInterface = getNewWebSocketForScreenShare()
        
        let loggingEnabled: Bool = coreDataLayer.getAppConfig().isDebug
        
        return TractRemoteSharePublisher(
            webSocket: webSocket,
            webSocketChannelPublisher: ActionCableChannelPublisher(webSocket: webSocket, loggingEnabled: loggingEnabled),
            loggingEnabled: loggingEnabled
        )
    }
    
    func  getTractRemoteShareSubscriber() -> TractRemoteShareSubscriber {
        
        let webSocket: WebSocketInterface = getNewWebSocketForScreenShare()
        
        let loggingEnabled: Bool = coreDataLayer.getAppConfig().isDebug
        
        return TractRemoteShareSubscriber(
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
}
