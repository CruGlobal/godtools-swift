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
    
    // MARK: - Data Layer Classes
    
    private func getGlobalAnalyticsRepository() -> GlobalAnalyticsRepository {
        
        return GlobalAnalyticsRepository(
            api: MobileContentGlobalAnalyticsApi(
                baseUrl: coreDataLayer.getAppConfig().getMobileContentApiBaseUrl(),
                urlSessionPriority: coreDataLayer.getSharedUrlSessionPriority()
            ),
            cache: RealmGlobalAnalyticsCache(
                realmDatabase: coreDataLayer.getSharedRealmDatabase()
            )
        )
    }
    
    // MARK: - Domain Interface
    
    func getGlobalActivityIsEnabled() -> GetGlobalActivityIsEnabledInterface {
        return GetGlobalActivityIsEnabled(
            remoteConfigRepository: coreDataLayer.getRemoteConfigRepository()
        )
    }
    
    func getGlobalActivityThisWeekRepository() -> GetGlobalActivityThisWeekRepositoryInterface {
        
        return GetGlobalActivityThisWeekRepository(
            globalAnalyticsRepository: getGlobalAnalyticsRepository(),
            localizationServices: coreDataLayer.getLocalizationServices(),
            getTranslatedNumberCount: coreDataLayer.getTranslatedNumberCount()
        )
    }
}
