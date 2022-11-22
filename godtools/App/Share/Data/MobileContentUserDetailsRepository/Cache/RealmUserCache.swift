//
//  RealmUserCache.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmUserCache {
    
    private let realmDatabase: RealmDatabase
    private let userSync: RealmUserCacheSync
    
    init(realmDatabase: RealmDatabase, userSync: RealmUserCacheSync) {
        
        self.realmDatabase = realmDatabase
        self.userSync = userSync
    }
    
    func getUserChanged() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm().objects(RealmUser.self)
            .objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getUser() -> UserDataModel? {
        guard let realmUser = realmDatabase.openRealm().objects(RealmUser.self).first else { return nil }
        
        return UserDataModel(realmUser: realmUser)
    }
    
    func syncUser(_ user: UserDataModel) -> AnyPublisher<UserDataModel, Error> {
        
        return userSync.syncUser(user: user)
    }
}
