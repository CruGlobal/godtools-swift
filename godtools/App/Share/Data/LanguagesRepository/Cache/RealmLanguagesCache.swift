//
//  RealmLanguagesCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmLanguagesCache {
    
    private let realmDatabase: RealmDatabase
    private let languagesSync: RealmLanguagesCacheSync

    init(realmDatabase: RealmDatabase, languagesSync: RealmLanguagesCacheSync) {
        
        self.realmDatabase = realmDatabase
        self.languagesSync = languagesSync
    }
    
    func getLanguage(code: String) -> LanguageDataModel? {
                
        guard let realmLanguage = realmDatabase.openRealm()
            .objects(RealmLanguage.self).filter(NSPredicate(format: "code".appending(" = [c] %@"), code.lowercased()))
            .first else {
            
            return nil
        }
        
        return LanguageDataModel(interface: realmLanguage)
    }
    
    func getLanguages(ids: [String]) -> [LanguageDataModel] {
        
        return realmDatabase.openRealm()
            .objects(RealmLanguage.self)
            .filter("id IN %@", ids)
            .map {
                LanguageDataModel(interface: $0)
            }
    }
    
    func getLanguages(languageCodes: [String]) -> [LanguageDataModel] {
    
        return languageCodes.compactMap({ getLanguage(code: $0) })
    }
    
    func getLanguages(realm: Realm? = nil) -> [LanguageDataModel] {
        
        let realmInstance: Realm = realm ?? realmDatabase.openRealm()
        
        return realmInstance.objects(RealmLanguage.self)
            .map({LanguageDataModel(interface: $0)})
    }
    
    func getLanguagesPublisher() -> AnyPublisher<[LanguageDataModel], Never> {
        
        return realmDatabase.readObjectsPublisher { (results: Results<RealmLanguage>) in
            results.map({
                LanguageDataModel(interface: $0)
            })
        }
        .eraseToAnyPublisher()
    }
        
    func syncLanguages(languages: [LanguageCodable]) -> AnyPublisher<RealmLanguagesCacheSyncResult, Error> {

        return languagesSync.syncLanguages(languages: languages)
    }
}
