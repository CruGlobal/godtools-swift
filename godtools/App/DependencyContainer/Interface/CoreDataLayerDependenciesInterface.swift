//
//  CoreDataLayerDependenciesInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import LocalizationServices
import RequestOperation

protocol CoreDataLayerDependenciesInterface {
    
    func getFavoritedResourcesRepository() -> FavoritedResourcesRepository
    func getLaunchCountRepository() -> LaunchCountRepositoryInterface
    func getLanguagesRepository() -> LanguagesRepository
    func getLocalizationServices() -> LocalizationServicesInterface
    func getRequestSender() -> RequestSender
    func getResourcesRepository() -> ResourcesRepository
    func getToolListItemInterfaceStringsRepository() -> GetToolListItemInterfaceStringsRepository
    func getTranslatedToolCategory() -> GetTranslatedToolCategory
    func getTranslatedToolLanguageAvailability() -> GetTranslatedToolLanguageAvailability
    func getTranslatedToolName() -> GetTranslatedToolName
    func getUserDefaultsCache() -> UserDefaultsCacheInterface
}
