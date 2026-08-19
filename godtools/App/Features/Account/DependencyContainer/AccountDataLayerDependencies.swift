//
//  AccountDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class AccountDataLayerDependencies: Sendable {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    private func getUserDetailsApi() -> UserDetailsApi {
        
        return UserDetailsApi(
            config: coreDataLayer.getAppConfig(),
            urlSessionPriority: coreDataLayer.getSharedUrlSessionPriority(),
            mobileContentApiAuthSession: coreDataLayer.getMobileContentApiAuthSession()
        )
    }
    
    private func getUserDetailsCache() -> UserDetailsCache {
        
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
        
        return UserDetailsCache(
            persistence: persistence
        )
    }
        
    func getUserDetailsRepository() -> UserDetailsRepository {
        
        return UserDetailsRepository(
            api: getUserDetailsApi(),
            cache: getUserDetailsCache(),
            authTokenRepository: coreDataLayer.getMobileContentAuthTokenRepository()
        )
    }
    
    func getUserDetailsSync() -> UserDetailsSync {
        
        return UserDetailsSync(
            api: getUserDetailsApi(),
            cache: getUserDetailsCache()
        )
    }
}
