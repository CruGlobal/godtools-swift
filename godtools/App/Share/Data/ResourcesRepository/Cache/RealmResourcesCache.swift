//
//  RealmResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmResourcesCache {
    
    private let realmDatabase: RealmDatabase
    private let resourcesChangedNotificationName = Notification.Name("resourcesCache.notification.resourcesChanged")
        
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getResourcesChangedPublisher() -> NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: resourcesChangedNotificationName)
    }
    
    func getResource(id: String) -> ResourceModel? {
        
        guard let realmResource = realmDatabase.mainThreadRealm.object(ofType: RealmResource.self, forPrimaryKey: id) else {
            return nil
        }
        
        return ResourceModel(realmResource: realmResource)
    }
    
    func getResource(abbreviation: String) -> ResourceModel? {
        
        guard let realmResource = realmDatabase.mainThreadRealm.objects(RealmResource.self).filter("abbreviation = '\(abbreviation)'").first else {
            return nil
        }
        
        return ResourceModel(realmResource: realmResource)
    }
    
    func getResources(ids: [String]) -> [ResourceModel] {
        
        return realmDatabase.mainThreadRealm.objects(RealmResource.self)
            .filter("id IN %@", ids)
            .map{
                ResourceModel(realmResource: $0)
            }
    }
    
    func getResources() -> [ResourceModel] {
        return realmDatabase.mainThreadRealm.objects(RealmResource.self)
            .map({ResourceModel(realmResource: $0)})
    }
    
    func getResourceLanguages(id: String) -> [LanguageModel] {
        
        guard let realmResource = realmDatabase.mainThreadRealm.object(ofType: RealmResource.self, forPrimaryKey: id) else {
            return Array()
        }
        
        return realmResource.languages.map({LanguageModel(model: $0)})
    }
    
    func getResourceLanguageTranslation(resourceId: String, languageId: String) -> TranslationModel? {
        
        guard let realmResource = realmDatabase.mainThreadRealm.object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
            return nil
        }
        
        guard let realmTranslation = realmResource.latestTranslations.filter("language.id = '\(languageId)'").first else {
            return nil
        }
        
        return TranslationModel(realmTranslation: realmTranslation)
    }
    
    func getResourceLanguageTranslation(resourceId: String, languageCode: String) -> TranslationModel? {
        
        guard let realmResource = realmDatabase.mainThreadRealm.object(ofType: RealmResource.self, forPrimaryKey: resourceId) else {
            return nil
        }
        
        guard let realmTranslation = realmResource.latestTranslations.filter(NSPredicate(format: "language.code".appending(" = [c] %@"), languageCode.lowercased())).first else {
            return nil
        }

        return TranslationModel(realmTranslation: realmTranslation)
    }
    
    func storeResources(resources: [ResourceModel], deletesNonExisting: Bool) -> AnyPublisher<[ResourceModel], Error> {
        
        return Future() { promise in

            self.realmDatabase.background { (realm: Realm) in
                
                var resourcesToRemove: [RealmResource] = Array(realm.objects(RealmResource.self))
                var writeError: Error?
                
                do {
                    
                    try realm.write {
                        
                        for resource in resources {
                            
                            if let index = resourcesToRemove.firstIndex(where: {$0.id == resource.id}) {
                                resourcesToRemove.remove(at: index)
                            }
   
                            if let existingResource = realm.object(ofType: RealmResource.self, forPrimaryKey: resource.id) {
                                
                                existingResource.mapFrom(model: resource, shouldIgnoreMappingPrimaryKey: true)
                            }
                            else {
                                
                                let newResource: RealmResource = RealmResource()
                                newResource.mapFrom(model: resource, shouldIgnoreMappingPrimaryKey: false)
                                realm.add(newResource)
                            }
                        }
                        
                        if deletesNonExisting {
                            realm.delete(resourcesToRemove)
                        }
                        
                        writeError = nil
                    }
                }
                catch let error {
                    
                    writeError = error
                }
                
                if let writeError = writeError {
                    
                    promise(.failure(writeError))
                }
                else {
                    
                    NotificationCenter.default.post(
                        name: self.resourcesChangedNotificationName,
                        object: resources,
                        userInfo: nil
                    )
                                        
                    promise(.success(resources))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
