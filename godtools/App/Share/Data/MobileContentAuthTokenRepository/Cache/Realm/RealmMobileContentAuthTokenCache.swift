//
//  RealmMobileContentAuthTokenCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmMobileContentAuthTokenCache {
    
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.realmDatabase = realmDatabase
    }
    
    func getAuthTokenData(userId: String) -> RealmMobileContentAuthToken? {
            
        let realm: Realm = realmDatabase.openRealm()
        
        let realmAuthTokenData: RealmMobileContentAuthToken? = realm.object(ofType: RealmMobileContentAuthToken.self, forPrimaryKey: userId)
        
        return realmAuthTokenData
    }
    
    func storeAuthTokenData(authTokenData: MobileContentAuthTokenDataModel) -> Result<Void, Error> {
        
        let realm: Realm = realmDatabase.openRealm()
        
        let realmAuthTokenData = RealmMobileContentAuthToken()
        
        realmAuthTokenData.expirationDate = authTokenData.expirationDate
        realmAuthTokenData.userId = authTokenData.userId
        
        do {
    
            try realm.write {
                realm.add(realmAuthTokenData, update: .all)
            }
            
            return .success(())
        }
        catch let error {
            
            return .failure(error)
        }
    }
    
    func deleteAuthTokenData(userId: String) -> Result<Void, Error> {
        
        guard let realmAuthTokenData = getAuthTokenData(userId: userId) else {
            return .success(())
        }
        
        let realm: Realm = realmDatabase.openRealm()
        
        do {
            
            try realm.write {
                realm.delete(realmAuthTokenData)
            }
            
            return .success(())
        }
        catch let error {
            return .failure(error)
        }
    }
}
