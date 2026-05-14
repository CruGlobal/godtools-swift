//
//  ToolScreenShareDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class ToolScreenShareDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
        
    func getToolScreenShareTutorialViewsRepository() -> ToolScreenShareTutorialViewsRepository {
        
        let persistence: any Persistence<ToolScreenShareTutorialViewDataModel, ToolScreenShareTutorialViewDataModel>
        
        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                dataModelMapping: SwiftToolScreenShareTutorialViewMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                dataModelMapping: RealmToolScreenShareTutorialViewMapping()
            )
        }
        
        return ToolScreenShareTutorialViewsRepository(
            cache: ToolScreenShareTutorialViewsCache(
                persistence: persistence
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
