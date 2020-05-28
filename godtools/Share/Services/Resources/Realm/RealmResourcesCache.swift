//
//  RealmResourcesCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmResourcesCache: ResourcesCacheType {
    
    private let mainThreadRealm: Realm
    
    required init(mainThreadRealm: Realm) {
        
        self.mainThreadRealm = mainThreadRealm
    }
    
    func cacheResources(resources: ResourcesJson) {
        
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
                    for language in languagesList {
                        self?.cacheLanguage(language: language)
                    }
                }
            }
        }
    }
    
    private func cacheResource(resource: RealmResource) -> Error? {
        
        do {
            try mainThreadRealm.write {
                mainThreadRealm.add(resource, update: .modified)
            }
        }
        catch let error {
            return error
        }
        
        return nil
    }
    
    private func cacheLanguage(language: RealmLanguage) -> Error? {
        
        do {
            try mainThreadRealm.write {
                mainThreadRealm.add(language, update: .modified)
            }
        }
        catch let error {
            return error
        }
        
        return nil
    }
}
