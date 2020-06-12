//
//  ResourcesRealmCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ResourcesRealmCache: ResourcesCacheType {
    
    private let mainThreadRealm: Realm
    
    required init(mainThreadRealm: Realm) {
        
        self.mainThreadRealm = mainThreadRealm
    }
    
    func cacheResources(languages: [LanguageModel], resourcesPlusLatestTranslationsAndAttachments: ResourcesPlusLatestTranslationsAndAttachmentsModel, complete: @escaping ((_ error: ResourcesCacheError?) -> Void)) {
                
        DispatchQueue.global().async { [weak self] in
                   
            var realmObjectsToCache: [Object] = Array()
            var realmLanguagesDictionary: [String: RealmLanguage] = Dictionary()
            var realmResourcesDictionary: [String: RealmResource] = Dictionary()
            
            for language in languages {
                
                let realmLanguage: RealmLanguage = RealmLanguage()
                realmLanguage.mapFrom(model: language)
                realmLanguagesDictionary[realmLanguage.id] = realmLanguage
                realmObjectsToCache.append(realmLanguage)
            }
            
            for resource in resourcesPlusLatestTranslationsAndAttachments.resources {
                
                let realmResource = RealmResource()
                realmResource.mapFrom(model: resource)
                realmResourcesDictionary[realmResource.id] = realmResource
                realmObjectsToCache.append(realmResource)
            }
            
            for translation in resourcesPlusLatestTranslationsAndAttachments.translations {
                
                let realmTranslation = RealmTranslation()
                realmTranslation.mapFrom(model: translation)
                
                if let resourceId = translation.resource?.id {
                    realmTranslation.resource = realmResourcesDictionary[resourceId]
                }
                
                if let languageId = translation.language?.id {
                    realmTranslation.language = realmLanguagesDictionary[languageId]
                }
                
                realmObjectsToCache.append(realmTranslation)
            }
            
            for attachment in resourcesPlusLatestTranslationsAndAttachments.attachments {
                
                let realmAttachment = RealmAttachment()
                realmAttachment.mapFrom(model: attachment)
                
                if let resourceId = attachment.resource?.id {
                    realmAttachment.resource = realmResourcesDictionary[resourceId]
                }
                
                realmObjectsToCache.append(realmAttachment)
            }
            
            DispatchQueue.main.async { [weak self] in
                                
                if let realm = self?.mainThreadRealm {
                    
                    do {
                        try realm.write {
                            realm.add(realmObjectsToCache, update: .all)
                        }
                        
                        complete(nil)
                    }
                    catch let error {
                        complete(.failedToCacheResources(error: error))
                    }
                }
            }
        }
    }
    
    func getLanguages() -> [RealmLanguage] {
        return Array(mainThreadRealm.objects(RealmLanguage.self))
    }
    
    func getResources() -> [RealmResource] {
        return Array(mainThreadRealm.objects(RealmResource.self))
    }
}
