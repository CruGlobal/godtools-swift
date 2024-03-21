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
    
    var numberOfLanguages: Int {
        return realmDatabase.openRealm().objects(RealmLanguage.self).count
    }
    
    func getLanguagesChanged() -> AnyPublisher<Void, Never> {
        return realmDatabase.openRealm().objects(RealmLanguage.self).objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getLanguage(id: String) -> LanguageModel? {
        
        guard let realmLanguage = realmDatabase.openRealm().object(ofType: RealmLanguage.self, forPrimaryKey: id) else {
            return nil
        }
        
        return LanguageModel(model: realmLanguage)
    }
    
    func getLanguage(code: String) -> LanguageModel? {
                
        guard let realmLanguage = realmDatabase.openRealm().objects(RealmLanguage.self).filter(NSPredicate(format: "code".appending(" = [c] %@"), code.lowercased())).first else {
            return nil
        }
        
        return LanguageModel(model: realmLanguage)
    }
    
    func getLanguages(ids: [String]) -> [LanguageModel] {
        
        return realmDatabase.openRealm().objects(RealmLanguage.self)
            .filter("id IN %@", ids)
            .map{
                LanguageModel(model: $0)
            }
    }
    
    func getLanguages(languageCodes: [String]) -> [LanguageModel] {
    
        return languageCodes.compactMap({getLanguage(code:$0)})
    }
    
    func getLanguages(realm: Realm? = nil) -> [LanguageModel] {
        
        let realmInstance: Realm = realm ?? realmDatabase.openRealm()
        
        return realmInstance.objects(RealmLanguage.self)
            .map({LanguageModel(model: $0)})
    }
        
    func syncLanguages(languages: [LanguageModel]) -> AnyPublisher<RealmLanguagesCacheSyncResult, Error> {

        return languagesSync.syncLanguages(languages: languages)
    }
}
