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
    
    func syncUser(_ user: UserDataModel) -> AnyPublisher<UserDataModel, Error> {
        
        return userSync.syncUser(user: user)
    }
}
