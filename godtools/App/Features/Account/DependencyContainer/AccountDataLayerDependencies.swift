//
//  AccountDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AccountDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
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
    
    // MARK: - Domain Interface
    
    func getAccountInterfaceStringsRepositoryInterface() -> GetAccountInterfaceStringsRepositoryInterface {
        return GetAccountInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getAuthenticateUserInterface() -> AuthenticateUserInterface {
        return AuthenticateUser(
            userAuthentication: coreDataLayer.getUserAuthentication()
        )
    }
    
    func getDeleteAccountInterfaceStringsRepository() -> GetDeleteAccountInterfaceStringsRepositoryInterface {
        return GetDeleteAccountInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getDeleteAccountProgressInterfaceStringsRepository() -> GetDeleteAccountProgressInterfaceStringsInterface {
        return GetDeleteAccountProgressInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getDeleteUserDetails() -> DeleteUserDetailsInterface {
        return DeleteUserDetails(
            userDetailsRepository: getUserDetailsRepository()
        )
    }
    
    func getSocialCreateAccountInterfaceStringsRepositoryInterface() -> GetSocialCreateAccountInterfaceStringsRepositoryInterface {
        return GetSocialCreateAccountInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getSocialSignInInterfaceStringsRepositoryInterface() -> GetSocialSignInInterfaceStringsRepositoryInterface {
        return GetSocialSignInInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getUserAccountDetailsRepositoryInterface() -> GetUserAccountDetailsRepositoryInterface {
        return GetUserAccountDetailsRepository(
            userDetailsRepository: getUserDetailsRepository(),
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
