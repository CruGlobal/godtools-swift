//
//  GlobalActivityDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class GlobalActivityDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: GlobalActivityDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: GlobalActivityDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getGlobalActivityEnabledUseCase() -> GetGlobalActivityEnabledUseCase {
        return GetGlobalActivityEnabledUseCase(
            remoteConfigRepository: core.dataLayer.getRemoteConfigRepository()
        )
    }
    
    func getGlobalActivityThisWeekUseCase() -> GetGlobalActivityThisWeekUseCase {
        
        return GetGlobalActivityThisWeekUseCase(
            globalAnalyticsRepository: dataLayer.getGlobalAnalyticsRepository(),
            localizationServices: core.dataLayer.getLocalizationServices(),
            getTranslatedNumberCount: core.domainLayer.supporting.getTranslatedNumberCount()
        )
    }
}
