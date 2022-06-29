//
//  ResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

typealias ResourceFilter = (ResourceModel) -> Bool

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
    
    func getAllVisibleLessonsSorted(andFilteredBy additionalFilter: ResourceFilter? = nil) -> [ResourceModel] {
        return getSortedResources().filterForLessonTypes(andFilteredBy: additionalFilter)
    }
    
    func getAllVisibleToolsSorted(andFilteredBy additionalFilter: ResourceFilter? = nil) -> [ResourceModel] {
        return getSortedResources().filterForToolTypes(andFilteredBy: additionalFilter)
    }
    
    func getAllVisibleTools(andFilteredBy additionalFilter: ResourceFilter? = nil) -> [ResourceModel] {
        return getResources().filterForToolTypes(andFilteredBy: additionalFilter)
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
    
    func getResourceVariants(resourceId: String) -> [ResourceModel] {
        
        let predicate = NSPredicate(format: "metatoolId".appending(" = [c] %@"), resourceId)
        
        let realmResourceVariants: [RealmResource] = Array(realmDatabase.mainThreadRealm.objects(RealmResource.self).filter(predicate))
        
        return realmResourceVariants.map({ResourceModel(realmResource: $0)})
    }
}
