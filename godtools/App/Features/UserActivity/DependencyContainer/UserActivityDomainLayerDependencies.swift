//
//  UserActivityDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class UserActivityDomainLayerDependencies {
    
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
    
    func getUserActivityUseCase() -> GetUserActivityUseCase {
        return GetUserActivityUseCase(
            getUserActivityBadge: getUserActivityBadge(),
            getUserActivityStats: getUserActivityStats(),
            userCounterRepository: coreDataLayer.getUserCountersRepository(),
            completedTrainingTipRepository: coreDataLayer.getCompletedTrainingTipRepository()
        )
    }
}

// MARK: - Supporting

extension UserActivityDomainLayerDependencies {
    
    private func getUserActivityBadge() -> GetUserActivityBadge{
        return GetUserActivityBadge(
            localizationServices: coreDataLayer.getLocalizationServices(),
            stringWithLocaleCount: coreDataLayer.getStringWithLocaleCount()
        )
    }
    
    private func getUserActivityStats() -> GetUserActivityStats {
        return GetUserActivityStats(
            localizationServices: coreDataLayer.getLocalizationServices(),
            getTranslatedNumberCount: coreDomainLayer.supporting.getTranslatedNumberCount(),
            stringWithLocaleCount: coreDataLayer.getStringWithLocaleCount()
        )
    }
}
