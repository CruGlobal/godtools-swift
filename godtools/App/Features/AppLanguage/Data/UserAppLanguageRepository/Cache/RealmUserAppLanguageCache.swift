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
        
        return realmDatabase.readObjectPublisher(primaryKey: RealmUserAppLanguageCache.sharedUserId)
            .map { (realmUserAppLanguage: RealmUserAppLanguage?) in
                
                guard let realmUserAppLanguage = realmUserAppLanguage else {
                    return nil
                }
                
                return UserAppLanguageDataModel(realmUserAppLanguage: realmUserAppLanguage)
            }
            .eraseToAnyPublisher()
    }
    
    func getLanguageChangedPublisher() -> AnyPublisher<Void, Never> {
                
        return realmDatabase.openRealm().objects(RealmUserAppLanguage.self).objectWillChange
            .map { _ in
                Void()
            }
            .eraseToAnyPublisher()
    }
    
    func storeLanguage(languageId: BCP47LanguageIdentifier) {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let realmUserAppLanguage = RealmUserAppLanguage()
        realmUserAppLanguage.id = RealmUserAppLanguageCache.sharedUserId
        realmUserAppLanguage.languageId = languageId
        
        do {
            
            try realm.write {
                realm.add(realmUserAppLanguage, update: .all)
            }
        }
        catch let error {
            print(error)
        }
    }
}
