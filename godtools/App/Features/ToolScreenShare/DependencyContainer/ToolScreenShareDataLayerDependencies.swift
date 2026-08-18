//
//  ToolScreenShareDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class ToolScreenShareDataLayerDependencies: Sendable {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
        
    func getToolScreenShareTutorialViewsRepository() -> ToolScreenShareTutorialViewsRepository {
        
        let persistence: any Persistence<ToolScreenShareTutorialViewDataModel, ToolScreenShareTutorialViewDataModel>
        
        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftToolScreenShareTutorialViewMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                mapping: RealmToolScreenShareTutorialViewMapping()
            )
        }
        
        return ToolScreenShareTutorialViewsRepository(
            cache: ToolScreenShareTutorialViewsCache(
                persistence: persistence
            )
        )
    }
    
    func getTractRemoteSharePublisher() -> TractRemoteSharePublisher {
                
        let loggingEnabled: Bool = coreDataLayer.getAppBuild().isDebug
        
        return TractRemoteSharePublisher(
            connectionUrl: coreDataLayer.getAppConfig().getTractRemoteShareConnectionUrl(),
            channelPublisher: ACChannelPublisher(
                webSocket: coreDataLayer.getWebSocket(),
                loggingEnabled: loggingEnabled
            ),
            loggingEnabled: loggingEnabled
        )
    }
    
    func  getTractRemoteShareSubscriber() -> TractRemoteShareSubscriber {
                
        let loggingEnabled: Bool = coreDataLayer.getAppBuild().isDebug
        
        return TractRemoteShareSubscriber(
            connectionUrl: coreDataLayer.getAppConfig().getTractRemoteShareConnectionUrl(),
            channelSubscriber: ACChannelSubscriber(
                webSocket: coreDataLayer.getWebSocket(),
                loggingEnabled: loggingEnabled
            ),
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
