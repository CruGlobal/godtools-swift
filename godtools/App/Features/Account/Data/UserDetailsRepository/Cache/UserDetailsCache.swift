//
//  UserDetailsCache.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import Combine

class UserDetailsCache {
        
    private let persistence: any Persistence<UserDetailsDataModel, MobileContentApiUsersMeCodable>
    private let authTokenRepository: MobileContentAuthTokenRepository
    
    init(persistence: any Persistence<UserDetailsDataModel, MobileContentApiUsersMeCodable>, authTokenRepository: MobileContentAuthTokenRepository) {
                
        self.persistence = persistence
        self.authTokenRepository = authTokenRepository
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<UserDetailsDataModel, MobileContentApiUsersMeCodable, SwiftUserDetails>? {
        return persistence as? SwiftRepositorySyncPersistence<UserDetailsDataModel, MobileContentApiUsersMeCodable, SwiftUserDetails>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<UserDetailsDataModel, MobileContentApiUsersMeCodable, RealmUserDetails>? {
        return persistence as? RealmRepositorySyncPersistence<UserDetailsDataModel, MobileContentApiUsersMeCodable, RealmUserDetails>
    }
}

extension UserDetailsCache {

    func getAuthUserDetails() throws -> UserDetailsDataModel? {
        
        guard let userId = authTokenRepository.getUserId() else {
            return nil
        }
        
        return try persistence
            .getDataModel(id: userId)
    }
}
