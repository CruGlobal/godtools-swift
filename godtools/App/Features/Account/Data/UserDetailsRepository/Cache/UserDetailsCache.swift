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

final class UserDetailsCache {
        
    private let authTokenRepository: MobileContentAuthTokenRepository
    
    let persistence: any Persistence<UserDetailsDataModel, MobileContentApiUsersMeCodable>
    
    init(persistence: any Persistence<UserDetailsDataModel, MobileContentApiUsersMeCodable>, authTokenRepository: MobileContentAuthTokenRepository) {
                
        self.persistence = persistence
        self.authTokenRepository = authTokenRepository
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<UserDetailsDataModel, MobileContentApiUsersMeCodable, SwiftUserDetails>? {
        return persistence as? SwiftRepositorySyncPersistence<UserDetailsDataModel, MobileContentApiUsersMeCodable, SwiftUserDetails>
    }
    
    private var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<UserDetailsDataModel, MobileContentApiUsersMeCodable, RealmUserDetails>? {
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
