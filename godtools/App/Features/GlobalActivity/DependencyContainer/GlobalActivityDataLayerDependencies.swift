//
//  GlobalActivityDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@MainActor
final class GlobalActivityDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    private func getGlobalAnalyticsApi() -> GlobalAnalyticsApiInterface {
        return MobileContentGlobalAnalyticsApi(
            baseUrl: coreDataLayer.getAppConfig().getMobileContentApiBaseUrl(),
            urlSessionPriority: coreDataLayer.getSharedUrlSessionPriority(),
            requestSender: coreDataLayer.getRequestSender()
        )
    }
    
    private func getGlobalAnalyticsCache() -> GlobalAnalyticsCache {
        
        return GlobalAnalyticsCache(
            persistence: getGlobalAnalyticsPersistence()
        )
    }
    
    private func getGlobalAnalyticsPersistence() -> any Persistence<GlobalAnalyticsDataModel, MobileContentGlobalAnalyticsCodable> {
        
        let persistence: any Persistence<GlobalAnalyticsDataModel, MobileContentGlobalAnalyticsCodable>
        
        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftGlobalAnalyticsMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                mapping: RealmGlobalAnalyticsMapping()
            )
        }
        
        return persistence
    }
    
    func getGlobalAnalyticsRepository() -> GlobalAnalyticsRepository {
        return GlobalAnalyticsRepository(api: getGlobalAnalyticsApi(), cache: getGlobalAnalyticsCache())
    }
    
    func getGlobalAnalyticsSync() -> GlobalAnalyticsSync {
        return GlobalAnalyticsSync(api: getGlobalAnalyticsApi(), cache: getGlobalAnalyticsCache())
    }
}
