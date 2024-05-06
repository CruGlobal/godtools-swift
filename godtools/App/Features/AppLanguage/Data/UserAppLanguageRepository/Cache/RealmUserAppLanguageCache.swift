//
//  RealmUserAppLanguageCache.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmUserAppLanguageCache {
    
    private static let sharedUserId: String = "shared-user-id"
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getLanguage() -> UserAppLanguageDataModel? {
        
        let realm: Realm = realmDatabase.openRealm()
        
        guard let realmUserAppLanguage = realm.object(ofType: RealmUserAppLanguage.self, forPrimaryKey: RealmUserAppLanguageCache.sharedUserId) else {
            return nil
        }
        
        return UserAppLanguageDataModel(realmUserAppLanguage: realmUserAppLanguage)
    }
    
    func getLanguagePublisher() -> AnyPublisher<UserAppLanguageDataModel?, Never> {
        
        return realmDatabase.readObjectPublisher(primaryKey: RealmUserAppLanguageCache.sharedUserId, mapInBackgroundClosure: { (object: RealmUserAppLanguage?) -> UserAppLanguageDataModel? in
            
            guard let realmUserAppLanguage = object else {
                return nil
            }
            
            return UserAppLanguageDataModel(realmUserAppLanguage: realmUserAppLanguage)
        })
        .eraseToAnyPublisher()
    }
    
    func getLanguageChangedPublisher() -> AnyPublisher<Void, Never> {
                
        return realmDatabase.openRealm().objects(RealmUserAppLanguage.self).objectWillChange
            .map { _ in
                Void()
            }
            .eraseToAnyPublisher()
    }
    
    func storeLanguagePublisher(languageId: BCP47LanguageIdentifier) -> AnyPublisher<UserAppLanguageDataModel?, Error> {
        
        return realmDatabase.writeObjectsPublisher { (realm: Realm) -> [RealmUserAppLanguage] in
            
            let realmUserAppLanguage = RealmUserAppLanguage()
            realmUserAppLanguage.id = RealmUserAppLanguageCache.sharedUserId
            realmUserAppLanguage.languageId = languageId
            
            return [realmUserAppLanguage]
            
        } mapInBackgroundClosure: { (objects: [RealmUserAppLanguage]) -> [UserAppLanguageDataModel] in
            
            return objects.map({
                return UserAppLanguageDataModel(realmUserAppLanguage: $0)
            })
        }
        .map { (objects: [UserAppLanguageDataModel]) in
            return objects.first
        }
        .eraseToAnyPublisher()
    }
}
