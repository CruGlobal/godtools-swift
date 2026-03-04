//
//  GlobalActivityDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class GlobalActivityDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    func getGlobalAnalyticsRepository() -> GlobalAnalyticsRepository {
        
        return GlobalAnalyticsRepository(
            api: MobileContentGlobalAnalyticsApi(
                baseUrl: coreDataLayer.getAppConfig().getMobileContentApiBaseUrl(),
                urlSessionPriority: coreDataLayer.getSharedUrlSessionPriority(),
                requestSender: coreDataLayer.getRequestSender()
            ),
            cache: RealmGlobalAnalyticsCache(
                realmDatabase: coreDataLayer.getSharedLegacyRealmDatabase()
            )
        )
    }
}
