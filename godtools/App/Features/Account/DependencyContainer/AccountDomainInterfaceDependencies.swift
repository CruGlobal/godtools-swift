//
//  AccountDomainInterfaceDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 8/21/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class AccountDomainInterfaceDependencies {
    
    private let coreDataLayer: CoreDataLayerDependenciesInterface
    private let dataLayer: AccountDataLayerDependenciesInterface
    
    init(coreDataLayer: CoreDataLayerDependenciesInterface, dataLayer: AccountDataLayerDependenciesInterface) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }

    func getAccountInterfaceStringsRepository() -> GetAccountInterfaceStringsRepositoryInterface {
        return GetAccountInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getAuthenticateUser() -> AuthenticateUserInterface {
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
            userDetailsRepository: dataLayer.getUserDetailsRepository()
        )
    }
    
    func getSocialCreateAccountInterfaceStringsRepository() -> GetSocialCreateAccountInterfaceStringsRepositoryInterface {
        return GetSocialCreateAccountInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getSocialSignInInterfaceStringsRepository() -> GetSocialSignInInterfaceStringsRepositoryInterface {
        return GetSocialSignInInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getUserAccountDetailsRepository() -> GetUserAccountDetailsRepositoryInterface {
        return GetUserAccountDetailsRepository(
            userDetailsRepository: dataLayer.getUserDetailsRepository(),
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
