//
//  UserActivityDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 6/11/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class UserActivityDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: UserActivityDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: UserActivityDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getIncrementUserCounterUseCase() -> IncrementUserCounterUseCase {
        return IncrementUserCounterUseCase(
            userCountersRepository: core.dataLayer.getUserCountersRepository()
        )
    }
    
    func getUserActivityUseCase() -> GetUserActivityUseCase {
        return GetUserActivityUseCase(
            getUserActivityBadge: getUserActivityBadge(),
            getUserActivityStats: getUserActivityStats(),
            userCounterRepository: core.dataLayer.getUserCountersRepository(),
            completedTrainingTipRepository: core.dataLayer.getCompletedTrainingTipRepository()
        )
    }
}

// MARK: - Supporting

extension UserActivityDomainLayerDependencies {
    
    private func getUserActivityBadge() -> GetUserActivityBadge{
        return GetUserActivityBadge(
            localizationServices: core.dataLayer.getLocalizationServices(),
            stringWithLocaleCount: core.dataLayer.getStringWithLocaleCount()
        )
    }
    
    private func getUserActivityStats() -> GetUserActivityStats {
        return GetUserActivityStats(
            localizationServices: core.dataLayer.getLocalizationServices(),
            getTranslatedNumberCount: core.domainLayer.supporting.getTranslatedNumberCount(),
            stringWithLocaleCount: core.dataLayer.getStringWithLocaleCount()
        )
    }
}
