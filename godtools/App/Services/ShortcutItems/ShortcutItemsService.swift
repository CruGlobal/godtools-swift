//
//  ShortcutItemsService.swift
//  godtools
//
//  Created by Levi Eggert on 6/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import RealmSwift

class ShortcutItemsService: NSObject {
    
    private let realmDatabase: RealmDatabase
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let favoritedResourcesCache: FavoritedResourcesCache
    
    required init(realmDatabase: RealmDatabase, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, favoritedResourcesCache: FavoritedResourcesCache) {
        
        self.realmDatabase = realmDatabase
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.favoritedResourcesCache = favoritedResourcesCache
        
        super.init()
        
        setupBinding()
    }
    
    deinit {
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
    }
    
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                if cachedResourcesAvailable {
                    self?.reloadShortcutItems(application: UIApplication.shared)
                }
            }
        }
        
        dataDownloader.resourcesUpdatedFromRemoteDatabase.addObserver(self) { [weak self] (error: InitialDataDownloaderError?) in
            DispatchQueue.main.async { [weak self] in
                if error == nil {
                    self?.reloadShortcutItems(application: UIApplication.shared)
                }
            }
        }
    }
    
    func reloadShortcutItems(application: UIApplication) {
        getShortcutItems { (shortcutItems: [UIApplicationShortcutItem]) in
            DispatchQueue.main.async {
                application.shortcutItems = shortcutItems
            }
        }
    }
    
    func getShortcutItems(complete: @escaping ((_ shortcutItems: [UIApplicationShortcutItem]) -> Void)) {
        
        realmDatabase.background { [weak self] (realm: Realm) in
            
            var shortcutItems: [UIApplicationShortcutItem] = Array()
            
            shortcutItems.append(contentsOf: self?.getTractShortcutItems(realm: realm) ?? [])
            
            complete(shortcutItems)
        }
    }
    
    private func getTractShortcutItems(realm: Realm) -> [UIApplicationShortcutItem] {
        
        var shortcutItems: [UIApplicationShortcutItem] = Array()
        
        let primaryLanguageId: String = languageSettingsService.primaryLanguage.value?.id ?? ""
        let parallelLanguageId: String = languageSettingsService.parallelLanguage.value?.id ?? ""
        
        let primaryLanguageCode: String = getLanguageCode(
            realm: realm,
            languageId: primaryLanguageId
        ) ?? "en"
        
        let parallelLanguageCode: String? = getLanguageCode(
            realm: realm,
            languageId: parallelLanguageId
        )

        let favoritedResources: [FavoritedResourceModel] = favoritedResourcesCache.getSortedFavoritedResources(realm: realm)
        
        guard !favoritedResources.isEmpty else {
            return []
        }
        
        if !favoritedResources.isEmpty {
            
            let maxShortcutCount: Int = 4
            var currentShortcutCount: Int = 0
            
            for favoritedResource in favoritedResources {
                
                if let resource = dataDownloader.resourcesCache.getRealmResource(realm: realm, id: favoritedResource.resourceId) {
                    
                    shortcutItems.append(ToolShortcutItem.shortcutItem(
                        resource: resource,
                        primaryLanguageCode: primaryLanguageCode,
                        parallelLanguageCode: parallelLanguageCode
                    ))
                    
                    currentShortcutCount += 1
                }
                
                if currentShortcutCount >= maxShortcutCount {
                    break
                }
            }
        }
        
        return shortcutItems
    }
    
    private func getLanguageCode(realm: Realm, languageId: String) -> String? {
        
        if !languageId.isEmpty, let language = realm.object(ofType: RealmLanguage.self, forPrimaryKey: languageId) {
            return language.code
        }
        else {
            return nil
        }
    }
}
