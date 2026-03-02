//
//  AccountDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RepositorySync

class AccountDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
        
    func getUserDetailsRepository() -> UserDetailsRepository {
        
        let persistence: any Persistence<UserDetailsDataModel, MobileContentApiUsersMeCodable>
        
        if #available(iOS 17.4, *), let database = coreDataLayer.getSharedSwiftDatabase() {
            
            persistence = SwiftRepositorySyncPersistence(
                database: database,
                dataModelMapping: SwiftUserDetailsMapping()
            )
        }
        else {
            
            persistence = RealmRepositorySyncPersistence(
                database: coreDataLayer.getSharedRealmDatabase(),
                dataModelMapping: RealmUserDetailsMapping()
            )
        }
        
        let api = UserDetailsAPI(
            config: coreDataLayer.getAppConfig(),
            urlSessionPriority: coreDataLayer.getSharedUrlSessionPriority(),
            mobileContentApiAuthSession: coreDataLayer.getMobileContentApiAuthSession()
        )
        
        let cache = UserDetailsCache(
            persistence: persistence,
            authTokenRepository: coreDataLayer.getMobileContentAuthTokenRepository()
        )
        
        return UserDetailsRepository(
            externalDataFetch: api,
            persistence: persistence,
            cache: cache
        )
    }
}
