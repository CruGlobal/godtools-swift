//
//  AccountDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class AccountDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
        
    func getUserDetailsRepository() -> UserDetailsRepository {
        
        let persistence: any Persistence<UserDetailsDataModel, MobileContentApiUsersMeCodable>
        
        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                mapping: SwiftUserDetailsMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                mapping: RealmUserDetailsMapping()
            )
        }
        
        let api = UserDetailsApi(
            config: coreDataLayer.getAppConfig(),
            urlSessionPriority: coreDataLayer.getSharedUrlSessionPriority(),
            mobileContentApiAuthSession: coreDataLayer.getMobileContentApiAuthSession()
        )
        
        let cache = UserDetailsCache(
            persistence: persistence
        )
        
        return UserDetailsRepository(
            api: api,
            cache: cache,
            authTokenRepository: coreDataLayer.getMobileContentAuthTokenRepository()
        )
    }
}
