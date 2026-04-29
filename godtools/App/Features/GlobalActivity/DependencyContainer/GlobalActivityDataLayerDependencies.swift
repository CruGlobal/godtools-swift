//
//  GlobalActivityDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RepositorySync

class GlobalActivityDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    func getGlobalAnalyticsRepository() -> GlobalAnalyticsRepository {
        
        let persistence: any Persistence<GlobalAnalyticsDataModel, MobileContentGlobalAnalyticsCodable>
        
        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                dataModelMapping: SwiftGlobalAnalyticsMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                dataModelMapping: RealmGlobalAnalyticsMapping()
            )
        }
        
        return GlobalAnalyticsRepository(
            api: MobileContentGlobalAnalyticsApi(
                baseUrl: coreDataLayer.getAppConfig().getMobileContentApiBaseUrl(),
                urlSessionPriority: coreDataLayer.getSharedUrlSessionPriority(),
                requestSender: coreDataLayer.getRequestSender()
            ),
            cache: GlobalAnalyticsCache(
                persistence: persistence
            )
        )
    }
}
