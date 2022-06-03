//
//  ResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ResourcesCache {
    
    private let realmDatabase: RealmDatabase
    
    required init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getResources() -> [ResourceModel] {
        let realm: Realm = realmDatabase.mainThreadRealm
        let realmResources: [RealmResource] = Array(realm.objects(RealmResource.self))
        return realmResources.map({ResourceModel(realmResource: $0)})
    }
    
    func getSortedResources() -> [ResourceModel] {
        let realm: Realm = realmDatabase.mainThreadRealm
        let sortedRealmResources: [RealmResource] = Array(realm.objects(RealmResource.self).sorted(byKeyPath: "attrDefaultOrder", ascending: true))
        return sortedRealmResources.map({ResourceModel(realmResource: $0)})
    }
    
    func getResources(resourceIds: [String]) -> [ResourceModel] {
        let realm: Realm = realmDatabase.mainThreadRealm
        var resources: [ResourceModel] = Array()
        for resourceId in resourceIds {
            if let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: resourceId) {
                resources.append(ResourceModel(realmResource: realmResource))
            }
        }
        return resources
    }
    
    func getAllVisibleToolsSorted(with additionalFilter: ((ResourceModel) -> Bool)? = nil) -> [ResourceModel] {
        return getSortedResources().filter { resource in
            
            if let additionalFilter = additionalFilter, additionalFilter(resource) == false {
                return false
            }
            
            return resource.isNotLessonType && resource.isHidden == false
        }
    }
    
    func getResource(id: String) -> ResourceModel? {
        let realm: Realm = realmDatabase.mainThreadRealm
        if let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: id) {
            return ResourceModel(realmResource: realmResource)
        }
        return nil
    }
    
    func getRealmResource(realm: Realm, id: String) -> RealmResource? {
        if let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: id) {
            return realmResource
        }
        return nil
    }
    
    func getResource(abbreviation: String) -> ResourceModel? {
        let realm: Realm = realmDatabase.mainThreadRealm
        if let realmResource = realm.objects(RealmResource.self).filter("abbreviation = '\(abbreviation)'").first {
            return ResourceModel(realmResource: realmResource)
        }
        return nil
    }
    
    func getResourceLanguages(resourceId: String) -> [LanguageModel] {
        let realm: Realm = realmDatabase.mainThreadRealm
        if let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: resourceId) {
            let realmLanguages: [RealmLanguage] = Array(realmResource.languages)
            return realmLanguages.map({LanguageModel(model: $0)})
        }
        return []
    }
    
    func getResourceLanguageTranslation(resourceId: String, languageId: String) -> TranslationModel? {
        
        let realm: Realm = realmDatabase.mainThreadRealm
        let realmResource: RealmResource? = realm.object(ofType: RealmResource.self, forPrimaryKey: resourceId)
        let realmTranslation: RealmTranslation? = realmResource?.latestTranslations.filter("language.id = '\(languageId)'").first
        let translation: TranslationModel?
        if let realmTranslation = realmTranslation {
            translation = TranslationModel(realmTranslation: realmTranslation)
        }
        else {
            translation = nil
        }
        return translation
    }
    
    func getResourceLanguageTranslation(resourceId: String, languageCode: String) -> TranslationModel? {
        
        let realm: Realm = realmDatabase.mainThreadRealm
        let realmResource: RealmResource? = realm.object(ofType: RealmResource.self, forPrimaryKey: resourceId)
        let realmTranslation: RealmTranslation? = realmResource?.latestTranslations.filter(NSPredicate(format: "language.code".appending(" = [c] %@"), languageCode.lowercased())).first
        let translation: TranslationModel?
        if let realmTranslation = realmTranslation {
            translation = TranslationModel(realmTranslation: realmTranslation)
        }
        else {
            translation = nil
        }
        return translation
    }
}
