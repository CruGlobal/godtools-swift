//
//  UserActivityDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class UserActivityDomainLayerDependencies {
    
    private let dataLayer: UserActivityDataLayerDependencies
    private let coreDataLayer: AppDataLayerDependencies
    
    init(dataLayer: UserActivityDataLayerDependencies, coreDataLayer: AppDataLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.coreDataLayer = coreDataLayer
    }
    
    func getUserActivityBadgeUseCase() -> GetUserActivityBadgeUseCase {
        return GetUserActivityBadgeUseCase(
            localizationServices: dataLayer.getLocalizationServices(),
            stringWithLocaleCount: dataLayer.getStringWithLocaleCount()
        )
    }
    
    func getUserActivityStatsUseCase() -> GetUserActivityStatsUseCase {
        return GetUserActivityStatsUseCase(
            localizationServices: dataLayer.getLocalizationServices(),
            getTranslatedNumberCount: dataLayer.getTranslatedNumberCount(),
            stringWithLocaleCount: dataLayer.getStringWithLocaleCount()
        )
    }
    
    func getUserActivityUseCase() -> GetUserActivityUseCase {
        return GetUserActivityUseCase(
            getUserActivityBadgeUseCase: getUserActivityBadgeUseCase(),
            getUserActivityStatsUseCase: getUserActivityStatsUseCase(),
            userCounterRepository: dataLayer.getUserCountersRepository(),
            completedTrainingTipRepository: dataLayer.getCompletedTrainingTipRepository()
        )
    }
}
