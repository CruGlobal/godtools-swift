//
//  OnboardingDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class OnboardingDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    private func getOnboardingTutorialViewedRepository() -> OnboardingTutorialViewedRepository {
        return OnboardingTutorialViewedRepository(
            cache: OnboardingTutorialViewedUserDefaultsCache(sharedUserDefaultsCache: coreDataLayer.getSharedUserDefaultsCache())
        )
    }
    
    // MARK: - Domain Interface
    
    func getOnboardingQuickStartInterfaceStringsRepositoryInterface() -> GetOnboardingQuickStartInterfaceStringsRepositoryInterface {
        return GetOnboardingQuickStartInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getOnboardingQuickStartLinksRepositoryInterface() -> GetOnboardingQuickStartLinksRepositoryInterface {
        return GetOnboardingQuickStartLinksRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getOnboardingQuickStartSupportedLanguagesRepositoryInterface() -> GetOnboardingQuickStartSupportedLanguagesRepositoryInterface {
        return GetOnboardingQuickStartSupportedLanguagesRepository()
    }
    
    func getOnboardingTutorialInterfaceStringsRepositoryInterface() -> GetOnboardingTutorialInterfaceStringsRepositoryInterface {
        return GetOnboardingTutorialInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getOnboardingTutorialViewedRepositoryInterface() -> GetOnboardingTutorialViewedRepositoryInterface {
        return GetOnboardingTutorialViewedRepository(
            onboardingTutorialViewedRepository: getOnboardingTutorialViewedRepository()
        )
    }
    
    func getStoreOnboardingTutorialViewedRepositoryInterface() -> StoreOnboardingTutorialViewedRepositoryInterface {
        return StoreOnboardingTutorialViewedRepository(
            onboardingTutorialViewedRepository: getOnboardingTutorialViewedRepository()
        )
    }
}
