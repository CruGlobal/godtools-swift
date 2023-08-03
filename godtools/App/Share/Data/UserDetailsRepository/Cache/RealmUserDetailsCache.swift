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
    private let authTokenRepository: MobileContentAuthTokenRepository
    
    init(realmDatabase: RealmDatabase, userDetailsSync: RealmUserDetailsCacheSync, authTokenRepository: MobileContentAuthTokenRepository) {
        
        self.realmDatabase = realmDatabase
        self.userDetailsSync = userDetailsSync
        self.authTokenRepository = authTokenRepository
    }
    
    func getUserDetailsChanged() -> AnyPublisher<Void, Never> {
        
        return realmDatabase.openRealm().objects(RealmUserDetails.self)
            .objectWillChange
            .eraseToAnyPublisher()
    }
    
    func getAuthUserDetails() -> UserDetailsDataModel? {
        
        guard let userId = authTokenRepository.getUserId() else {
            return nil
        }
        
        guard let realmUserDetails = realmDatabase.openRealm().object(ofType: RealmUserDetails.self, forPrimaryKey: userId) else {
            return nil
        }
        
        return UserDetailsDataModel(realmUserDetails: realmUserDetails)
    }
    
    func syncUserDetails(_ userDetails: UserDetailsDataModel) -> AnyPublisher<UserDetailsDataModel, Error> {
        
        return userDetailsSync.syncUserDetails(userDetails)
    }
}
