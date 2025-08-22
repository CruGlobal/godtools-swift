//
//  AccountDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AccountDataLayerDependencies: AccountDataLayerDependenciesInterface {
    
    private let coreDataLayer: CoreDataLayerDependenciesInterface
    
    init(coreDataLayer: CoreDataLayerDependenciesInterface) {
        
        self.coreDataLayer = coreDataLayer
    }
        
    func getUserDetailsRepository() -> UserDetailsRepository {
        return UserDetailsRepository(
            api: UserDetailsAPI(
                config: coreDataLayer.getAppConfig(),
                urlSessionPriority: coreDataLayer.getSharedUrlSessionPriority(),
                mobileContentApiAuthSession: coreDataLayer.getMobileContentApiAuthSession()
            ),
            cache: RealmUserDetailsCache(
                realmDatabase: coreDataLayer.getSharedRealmDatabase(),
                authTokenRepository: coreDataLayer.getMobileContentAuthTokenRepository()
            )
        )
    }
}
