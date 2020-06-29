//
//  ShortcutItemsService.swift
//  godtools
//
//  Created by Levi Eggert on 6/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import RealmSwift

class ShortcutItemsService {
    
    private let realmDatabase: RealmDatabase
    private let languageSettingsCache: LanguageSettingsCacheType
    
    required init(realmDatabase: RealmDatabase, languageSettingsCache: LanguageSettingsCacheType) {
        
        self.realmDatabase = realmDatabase
        self.languageSettingsCache = languageSettingsCache
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
        
        let primaryLanguageId: String = languageSettingsCache.primaryLanguageId.value ?? ""
        let parallelLanguageId: String = languageSettingsCache.parallelLanguageId.value ?? ""
        
        let primaryLanguageCode: String = getLanguageCode(
            realm: realm,
            languageId: primaryLanguageId
        ) ?? "en"
        
        let parallelLanguageCode: String? = getLanguageCode(
            realm: realm,
            languageId: parallelLanguageId
        )

        let resources: [RealmResource] = Array(realm.objects(RealmResource.self))
        
        for resource in resources {
            
            shortcutItems.append(ToolShortcutItem(
                resource: resource,
                primaryLanguageCode: primaryLanguageCode,
                parallelLanguageCode: parallelLanguageCode
            ))
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
