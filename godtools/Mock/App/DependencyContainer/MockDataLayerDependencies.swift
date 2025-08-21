//
//  MockDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import LocalizationServices
import RequestOperation

class MockDataLayerDependencies: CoreDataLayerDependenciesInterface {
    
    private let sharedUserDefaults: MockSharedUserDefaultsCache = MockSharedUserDefaultsCache()
    private let coreDataLayer: AppDataLayerDependencies // NOTE: For now I don't want to create interfaces for all the RealmDatabase repositories. However, that may slowly be worked in and this can be removed. ~Levi
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    func getFavoritedResourcesRepository() -> FavoritedResourcesRepository {
        return coreDataLayer.getFavoritedResourcesRepository()
    }
    
    func getLaunchCountRepository() -> LaunchCountRepositoryInterface {
        return MockLaunchCountRepository(launchCount: 0)
    }
    
    func getLanguagesRepository() -> LanguagesRepository {
        return coreDataLayer.getLanguagesRepository()
    }
    
    func getLocalizationServices() -> LocalizationServicesInterface {
        return MockLocalizationServices(localizableStrings: [:])
    }
    
    func getRequestSender() -> RequestSender {
        return DoesNotSendUrlRequestSender()
    }
    
    func getResourcesRepository() -> ResourcesRepository {
        return coreDataLayer.getResourcesRepository()
    }
    
    func getToolListItemInterfaceStringsRepository() -> GetToolListItemInterfaceStringsRepository {
        return coreDataLayer.getToolListItemInterfaceStringsRepository()
    }
    
    func getTranslatedToolCategory() -> GetTranslatedToolCategory {
        return coreDataLayer.getTranslatedToolCategory()
    }
    
    func getTranslatedToolLanguageAvailability() -> GetTranslatedToolLanguageAvailability {
        return coreDataLayer.getTranslatedToolLanguageAvailability()
    }
    
    func getTranslatedToolName() -> GetTranslatedToolName {
        return coreDataLayer.getTranslatedToolName()
    }

    func getUserDefaultsCache() -> UserDefaultsCacheInterface {
        return sharedUserDefaults
    }
}
