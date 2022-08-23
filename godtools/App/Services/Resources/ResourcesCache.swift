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
        return realmResources.map({ResourceModel(model: $0)})
    }
    
    func getSortedResources() -> [ResourceModel] {
        let realm: Realm = realmDatabase.mainThreadRealm
        let sortedRealmResources: [RealmResource] = Array(realm.objects(RealmResource.self).sorted(byKeyPath: "attrDefaultOrder", ascending: true))
        return sortedRealmResources.map({ResourceModel(model: $0)})
    }
    
    func getResourcesWithoutMetaToolVariants() -> [ResourceModel] {
        let realm: Realm = realmDatabase.mainThreadRealm
        let resourcesWithoutVariants: [RealmResource] = Array(realm.objects(RealmResource.self).filter(NSPredicate(format: "%K == nil || %K == ''", #keyPath(RealmResource.metatoolId), #keyPath(RealmResource.metatoolId))))
        return resourcesWithoutVariants.map { ResourceModel(model: $0) }
    }
    
    func getResources(resourceIds: [String]) -> [ResourceModel] {
        let realm: Realm = realmDatabase.mainThreadRealm
        var resources: [ResourceModel] = Array()
        for resourceId in resourceIds {
            if let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: resourceId) {
                resources.append(ResourceModel(model: realmResource))
            }
        }
        return resources
    }
    
    func getAllVisibleLessonsSorted(andFilteredBy additionalFilter: ResourceFilter? = nil) -> [ResourceModel] {
        return getSortedResources().filterForLessonTypes(andFilteredBy: additionalFilter)
    }
    
    func getAllVisibleTools(andFilteredBy additionalFilter: ResourceFilter? = nil) -> [ResourceModel] {
        let defaultVariantIds = getMetaTools().compactMap { $0.defaultVariantId }
        let defaultVariants = getResources(resourceIds: defaultVariantIds)
        
        let resourcesExcludingVariants = getResourcesWithoutMetaToolVariants()
        
        let combinedResourcesAndDefaultVariants = resourcesExcludingVariants + defaultVariants
        
        return combinedResourcesAndDefaultVariants.filterForToolTypes(andFilteredBy: additionalFilter)
    }
    
    func getAllVisibleToolsSorted(andFilteredBy additionalFilter: ResourceFilter? = nil) -> [ResourceModel] {
        return getAllVisibleTools(andFilteredBy: additionalFilter).sortedByDefaultOrder()
    }
    
    func getMetaTools() -> [ResourceModel] {
        let realm: Realm = realmDatabase.mainThreadRealm
        let metaToolResources: [RealmResource] = Array(realm.objects(RealmResource.self).where { $0.resourceType == ResourceType.metaTool.rawValue })
        return metaToolResources.map { ResourceModel(model: $0) }
    }
    
    func getToolsWithAbbreviations(_ abbreviatons: [String]) -> [ResourceModel] {
        let realm: Realm = realmDatabase.mainThreadRealm
        let resources: [RealmResource] = Array(realm.objects(RealmResource.self).filter(NSPredicate(format: "%K IN %@", #keyPath(RealmResource.abbreviation), abbreviatons)))
        return resources.map { ResourceModel(model: $0) }
    }
    
    func getResource(id: String) -> ResourceModel? {
        let realm: Realm = realmDatabase.mainThreadRealm
        if let realmResource = realm.object(ofType: RealmResource.self, forPrimaryKey: id) {
            return ResourceModel(model: realmResource)
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
            return ResourceModel(model: realmResource)
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
            translation = TranslationModel(model: realmTranslation)
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
            translation = TranslationModel(model: realmTranslation)
        }
        else {
            translation = nil
        }
        return translation
    }
}
