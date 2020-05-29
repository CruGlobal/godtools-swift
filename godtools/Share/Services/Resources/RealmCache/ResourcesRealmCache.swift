//
//  ResourcesRealmCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class ResourcesRealmCache {
    
    private let mainThreadRealm: Realm
    
    required init(mainThreadRealm: Realm) {
        
        self.mainThreadRealm = mainThreadRealm
    }
    
    func cacheResources(resources: ResourcesJson) {
        
        print("\n CACHE RESOURCES")
        
        DispatchQueue.global().async { [weak self] in
            
            var realmLanguagesToCache: [RealmLanguage] = Array()
            var realmLanguagesDictionary: [String: RealmLanguage] = Dictionary()
            
            let jsonServices = JsonServices()
            
            let decodedLanguagesResult: Result<RealmLanguagesData?, Error> = jsonServices.decodeObject(data: resources.languagesJson)
            
            switch decodedLanguagesResult {
            case .success(let realmLanguagesObject):
                if let languages = realmLanguagesObject?.data {
                    for language in languages {
                        realmLanguagesToCache.append(language)
                        realmLanguagesDictionary[language.id] = language
                    }
                }
            case .failure(let error):
                // TODO: Handle error.
                assertionFailure("Failed to decode realm languages: \(error)")
            }
            
            // TODO: Decode resources and latest translations and attachments
            
            let decodedResourcesResult: Result<RealmResourcesData?, Error> = jsonServices.decodeObject(data: resources.resourcesPlusLatestTranslationsAndAttachmentsJson)
            
            
            DispatchQueue.main.async { [weak self] in
                
                if let realm = self?.mainThreadRealm {
                    
                    do {
                        try realm.write {
                            realm.delete(realm.objects(RealmLanguage.self))
                            realm.delete(realm.objects(RealmResource.self))
                            realm.delete(realm.objects(RealmTranslation.self))
                            // TODO: Delete attachments.
                            
                            realm.add(realmLanguagesToCache, update: .modified)
                        }
                    }
                    catch let error {
                        // TODO: Handle error.
                        assertionFailure("Failed to cache realm resources: \(error)")
                    }
                }
                
                
            }
        }
    }
    
    func getLanguages() {
        
        let cachedLanguages: [RealmLanguage] = Array(mainThreadRealm.objects(RealmLanguage.self))
        print("  number of cached languages: \(cachedLanguages.count)")
        
        let cachedTranslations: [RealmTranslation] = Array(mainThreadRealm.objects(RealmTranslation.self))
        print("  number of cached translations: \(cachedTranslations.count)")
        for translation in cachedTranslations {
            print("  translation id: \(translation.id)")
            print("    translation LANGUAGE CODE: \(translation.language?.attributes?.code)")
        }
    }
}
