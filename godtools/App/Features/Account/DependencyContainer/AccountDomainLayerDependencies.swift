//
//  AccountDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AccountDomainLayerDependencies {
    
    // TODO: Need to refactor so reference (coreDataLayer: AppDataLayerDependencies) is not in this class. UseCases should only point to interfaces for dependency inversion. ~Levi
    private let coreDataLayer: AppDataLayerDependencies
    private let domainInterfaceLayer: AccountDomainInterfaceDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, domainInterfaceLayer: AccountDomainInterfaceDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.domainInterfaceLayer = domainInterfaceLayer
    }
    
    func getAccountCreationIsSupportedUseCase() -> GetAccountCreationIsSupportedUseCase {
        return GetAccountCreationIsSupportedUseCase()
    }
    
    func getAuthenticateUserUseCase() -> AuthenticateUserUseCase {
        return AuthenticateUserUseCase(
            authenticateUser: domainInterfaceLayer.getAuthenticateUser(),
            emailSignUpService: coreDataLayer.getEmailSignUpService(),
            firebaseAnalytics: coreDataLayer.getAnalytics().firebaseAnalytics
        )
    }
    
    func getDeleteAccountUseCase() -> DeleteAccountUseCase {
        return DeleteAccountUseCase(
            userAuthentication: coreDataLayer.getUserAuthentication(),
            deleteUserDetails: domainInterfaceLayer.getDeleteUserDetails()
        )
    }
    
    func getDeleteUserCountersUseCase() -> DeleteUserCountersUseCase {
        return DeleteUserCountersUseCase(
            repository: coreDataLayer.getUserCountersRepository()
        )
    }
    
    func getLogOutUserUseCase() -> LogOutUserUseCase {
        return LogOutUserUseCase(
            userAuthentication: coreDataLayer.getUserAuthentication(),
            firebaseAnalytics: coreDataLayer.getAnalytics().firebaseAnalytics,
            deleteUserCountersUseCase: getDeleteUserCountersUseCase()
        )
    }
    
    func getSocialCreateAccountInterfaceStringsUseCase() -> GetSocialCreateAccountInterfaceStringsUseCase {
        return GetSocialCreateAccountInterfaceStringsUseCase(
            getInterfaceStringsRepositoryInterface: domainInterfaceLayer.getSocialCreateAccountInterfaceStringsRepository()
        )
    }
    
    func getSocialSignInInterfaceStringsUseCase() -> GetSocialSignInInterfaceStringsUseCase {
        return GetSocialSignInInterfaceStringsUseCase(
            getInterfaceStringsRepositoryInterface: domainInterfaceLayer.getSocialSignInInterfaceStringsRepository()
        )
    }
    
    func getUserAccountDetailsUseCase() -> GetUserAccountDetailsUseCase {
        return GetUserAccountDetailsUseCase(
            getUserAccountDetailsRepository: domainInterfaceLayer.getUserAccountDetailsRepository()
        )
    }
    
    func getUserIsAuthenticatedUseCase() -> GetUserIsAuthenticatedUseCase {
        return GetUserIsAuthenticatedUseCase(
            userAuthentication: coreDataLayer.getUserAuthentication()
        )
    }
    
    func getViewAccountUseCase() -> ViewAccountUseCase {
        return ViewAccountUseCase(
            getInterfaceStringsRepository: domainInterfaceLayer.getAccountInterfaceStringsRepository()
        )
    }
    
    func getViewDeleteAccountUseCase() -> ViewDeleteAccountUseCase {
        return ViewDeleteAccountUseCase(
            getInterfaceStringsRepository: domainInterfaceLayer.getDeleteAccountInterfaceStringsRepository()
        )
    }
    
    func getViewDeleteAccountProgressUseCase() -> ViewDeleteAccountProgressUseCase {
        return ViewDeleteAccountProgressUseCase(
            getInterfaceStringsRepository: domainInterfaceLayer.getDeleteAccountProgressInterfaceStringsRepository()
        )
    }
}
