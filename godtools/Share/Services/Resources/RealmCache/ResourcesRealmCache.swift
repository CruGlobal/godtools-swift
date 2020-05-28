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
    
    func cacheResources(resources: ResourcesJson) {
        
        print("\n CACHE RESOURCES")
        
        if let data = resources.languagesJson {
              
            let realmLanguagesData: RealmLanguagesData?
            
            do {
                realmLanguagesData = try JSONDecoder().decode(RealmLanguagesData.self, from: data)
            }
            catch let error {
                realmLanguagesData = nil
            }
            
            DispatchQueue.main.async { [weak self] in
                
                if let languagesList = realmLanguagesData?.data {
                   
                    print("  cache languages: \(Array(languagesList).count)")
                    
                    var realmLanguages: [RealmLanguage] = Array()
                    
                    for language in languagesList {
                                   
                        if let translations = language.relationships?.languageTranslations?.data {
                            for translation in translations {
                                translation.language = language
                            }
                        }
                        
                        realmLanguages.append(language)
                    }
                                        
                    self?.cacheObjects(objects: realmLanguages, updatePolicy: .modified, complete: { (error: Error?) in
                        
                    })
                    
                    print("\n DID CACHE ALL LANGUAGES")
                    self?.getLanguages()
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

    private func cacheObjects<T: Object>(objects: [T], updatePolicy: Realm.UpdatePolicy?, complete: @escaping ((_ error: Error?) -> Void)) {
        
        DispatchQueue.main.async { [weak self] in
            do {
                try self?.mainThreadRealm.write {
                    if let updatePolicy = updatePolicy {
                        self?.mainThreadRealm.add(objects, update: updatePolicy)
                    }
                    else {
                        self?.mainThreadRealm.add(objects)
                    }
                }
                complete(nil)
            }
            catch let error {
                complete(error)
            }
        }
    }
}
