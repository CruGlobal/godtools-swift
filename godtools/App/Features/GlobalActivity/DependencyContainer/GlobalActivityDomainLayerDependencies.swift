//
//  GlobalActivityDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class GlobalActivityDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: GlobalActivityDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: GlobalActivityDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getGlobalActivityEnabledUseCase() -> GetGlobalActivityEnabledUseCase {
        return GetGlobalActivityEnabledUseCase(
            remoteConfigRepository: coreDataLayer.getRemoteConfigRepository()
        )
    }
    
    func getGlobalActivityThisWeekUseCase() -> GetGlobalActivityThisWeekUseCase {
        
        return GetGlobalActivityThisWeekUseCase(
            globalAnalyticsRepository: dataLayer.getGlobalAnalyticsRepository(),
            localizationServices: coreDataLayer.getLocalizationServices(),
            getTranslatedNumberCount: coreDataLayer.getTranslatedNumberCount()
        )
    }
}
