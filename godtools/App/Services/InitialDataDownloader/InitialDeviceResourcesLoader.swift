//
//  InitialDeviceResourcesLoader.swift
//  godtools
//
//  Created by Levi Eggert on 6/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import RealmSwift

@available(*, deprecated) // TODO: This class is no longer needed as UseCases will determine any initial data. ~Levi
class InitialDeviceResourcesLoader {
    
    private let realmDatabase: RealmDatabase
    private let resourcesSync: InitialDataDownloaderResourcesSync
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let languagesCache: RealmLanguagesCache
    private let deviceLanguage: DeviceLanguage
        
    required init(realmDatabase: RealmDatabase, resourcesSync: InitialDataDownloaderResourcesSync, favoritedResourcesCache: FavoritedResourcesCache, languagesCache: RealmLanguagesCache, deviceLanguage: DeviceLanguage) {
        
        self.realmDatabase = realmDatabase
        self.resourcesSync = resourcesSync
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languagesCache = languagesCache
        self.deviceLanguage = deviceLanguage
    }
    
    func loadAndCacheInitialDeviceResourcesIfNeeded(completeOnMain: @escaping (() -> Void)) {
        
        setupInitialFavoritedResourcesAndLanguage()
    }
    
    @available(*, deprecated) // TODO: This logic should be handled in a UseCase.  See GT-1715. ~Levi
    private func setupInitialFavoritedResourcesAndLanguage() {
                
        favoritedResourcesCache.addToFavorites(resourceId: "2") //satisfied
        favoritedResourcesCache.addToFavorites(resourceId: "1") //knowing god personally
        favoritedResourcesCache.addToFavorites(resourceId: "4") //fourlaws
        favoritedResourcesCache.addToFavorites(resourceId: "8") //teach me to share
    }
}
