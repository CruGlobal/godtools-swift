//
//  UserActivityDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class UserActivityDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let coreDomainLayer: AppDomainLayerDependencies
    private let dataLayer: UserActivityDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies, dataLayer: UserActivityDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.coreDomainLayer = coreDomainLayer
        self.dataLayer = dataLayer
    }
    
    func getIncrementUserCounterUseCase() -> IncrementUserCounterUseCase {
        return IncrementUserCounterUseCase(
            userCountersRepository: coreDataLayer.getUserCountersRepository()
        )
    }
    
    func getUserActivityBadgeUseCase() -> GetUserActivityBadgeUseCase {
        return GetUserActivityBadgeUseCase(
            localizationServices: coreDataLayer.getLocalizationServices(),
            stringWithLocaleCount: coreDataLayer.getStringWithLocaleCount()
        )
    }
    
    func getUserActivityStatsUseCase() -> GetUserActivityStatsUseCase {
        return GetUserActivityStatsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices(),
            getTranslatedNumberCount: coreDomainLayer.supporting.getTranslatedNumberCount(),
            stringWithLocaleCount: coreDataLayer.getStringWithLocaleCount()
        )
    }
    
    func getUserActivityUseCase() -> GetUserActivityUseCase {
        return GetUserActivityUseCase(
            getUserActivityBadgeUseCase: getUserActivityBadgeUseCase(),
            getUserActivityStatsUseCase: getUserActivityStatsUseCase(),
            userCounterRepository: coreDataLayer.getUserCountersRepository(),
            completedTrainingTipRepository: coreDataLayer.getCompletedTrainingTipRepository()
        )
    }
}
