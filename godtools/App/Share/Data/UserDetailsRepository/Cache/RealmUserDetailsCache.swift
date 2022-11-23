//
//  RealmUserDetailsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

class RealmUserDetailsCache {
    
    private let realmDatabase: RealmDatabase
    private let userDetailsSync: RealmUserDetailsCacheSync
    
    init(realmDatabase: RealmDatabase, userDetailsSync: RealmUserDetailsCacheSync) {
        
        self.realmDatabase = realmDatabase
        self.userDetailsSync = userDetailsSync
    }
    
    func getUserDetailsChanged() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm().objects(RealmUserDetails.self)
            .objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getUserDetails() -> UserDetailsDataModel? {
        guard let realmUserDetails = realmDatabase.openRealm().objects(RealmUserDetails.self).first else { return nil }
        
        return UserDetailsDataModel(realmUserDetails: realmUserDetails)
    }
    
    func syncUserDetails(_ userDetails: UserDetailsDataModel) -> AnyPublisher<UserDetailsDataModel, Error> {
        
        return userDetailsSync.syncUserDetails(userDetails)
    }
}
