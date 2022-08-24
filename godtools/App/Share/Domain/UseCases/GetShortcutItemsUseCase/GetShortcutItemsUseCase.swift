//
//  GetShortcutItemsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class GetShortcutItemsUseCase {
    
    private let getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let resourcesRepository: ResourcesRepository
    private let maxShortcutItems: Int = 4
    
    init(getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, resourcesRepository: ResourcesRepository) {
     
        self.getAllFavoritedToolsUseCase = getAllFavoritedToolsUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.resourcesRepository = resourcesRepository
    }
    
    func getShortcutItems() -> [UIApplicationShortcutItem] {
        
        var shortcutItems: [UIApplicationShortcutItem] = Array()
        
        let primaryLanguageCode: String = getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.localeIdentifier ?? "en"
        let parallelLanguageCode: String? = getSettingsParallelLanguageUseCase.getParallelLanguage()?.localeIdentifier
        
        let favoritedResources: [FavoritedResourceModel] = getAllFavoritedToolsUseCase.getAllFavoritedTools()
        
        for favoritedResource in favoritedResources {
                        
            guard let resource = resourcesRepository.getResource(id: favoritedResource.resourceId) else {
                continue
            }
            
            guard shortcutItems.count < maxShortcutItems else {
                break
            }
            
            let shortcutItem = ToolShortcutItem.shortcutItem(
                resourcesRepository: resourcesRepository,
                resource: resource,
                primaryLanguageCode: primaryLanguageCode,
                parallelLanguageCode: parallelLanguageCode
            )
            
            shortcutItems.append(shortcutItem)
        }
        
        return shortcutItems
    }
    
    /*
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
    }*/
}
