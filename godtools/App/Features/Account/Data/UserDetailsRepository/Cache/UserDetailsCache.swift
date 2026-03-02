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
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<LanguageDataModel, LanguageCodable, SwiftLanguage>? {
        return persistence as? SwiftRepositorySyncPersistence<LanguageDataModel, LanguageCodable, SwiftLanguage>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<LanguageDataModel, LanguageCodable, RealmLanguage>? {
        return persistence as? RealmRepositorySyncPersistence<LanguageDataModel, LanguageCodable, RealmLanguage>
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
