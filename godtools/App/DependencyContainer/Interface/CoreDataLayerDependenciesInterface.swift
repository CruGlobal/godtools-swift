//
//  CoreDataLayerDependenciesInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import LocalizationServices

protocol CoreDataLayerDependenciesInterface {
    
    func getLaunchCountRepository() -> LaunchCountRepositoryInterface
    func getLocalizationServices() -> LocalizationServicesInterface
    func getUserDefaultsCache() -> UserDefaultsCacheInterface
}
