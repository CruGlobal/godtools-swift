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
    
    func getUserAppLanguage() -> UserAppLanguageDataModel? {
        
        let realm: Realm = realmDatabase.openRealm()
        
        guard let realmUserAppLanguage = realm.object(ofType: RealmUserAppLanguage.self, forPrimaryKey: RealmUserAppLanguageCache.sharedUserId) else {
            return nil
        }
        
        return UserAppLanguageDataModel(realmUserAppLanguage: realmUserAppLanguage)
    }
    
    func getUserAppLanguagePublisher() -> AnyPublisher<UserAppLanguageDataModel?, Never> {
        
        return realmDatabase.openRealm().objects(RealmUserAppLanguage.self).objectWillChange
            .flatMap({ _ -> AnyPublisher<UserAppLanguageDataModel?, Never> in
                
                let userAppLanguage: UserAppLanguageDataModel? = self.getUserAppLanguage()
                
                return Just(userAppLanguage)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func storeUserAppLanguage(languageCode: String) {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let realmUserAppLanguage = RealmUserAppLanguage()
        realmUserAppLanguage.id = RealmUserAppLanguageCache.sharedUserId
        realmUserAppLanguage.languageCode = languageCode
        
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
