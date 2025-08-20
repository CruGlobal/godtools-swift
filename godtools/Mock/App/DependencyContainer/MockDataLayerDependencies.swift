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
    
    func getLaunchCountRepository() -> LaunchCountRepositoryInterface {
        return MockLaunchCountRepository(launchCount: 0)
    }
    
    func getLocalizationServices() -> LocalizationServicesInterface {
        return MockLocalizationServices(localizableStrings: [:])
    }
    
    func getRequestSender() -> RequestSender {
        return DoesNotSendUrlRequestSender()
    }

    func getUserDefaultsCache() -> UserDefaultsCacheInterface {
        return sharedUserDefaults
    }
}
