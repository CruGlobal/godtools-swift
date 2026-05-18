//
//  AccountDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class AccountDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: AccountDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: AccountDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getAccountCreationIsSupportedUseCase() -> GetAccountCreationIsSupportedUseCase {
        return GetAccountCreationIsSupportedUseCase()
    }
    
    func getAccountStringsUseCase() -> GetAccountStringsUseCase {
        return GetAccountStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getAuthenticateUserUseCase() -> AuthenticateUserUseCase {
        return AuthenticateUserUseCase(
            userAuthentication: core.dataLayer.getUserAuthentication(),
            emailSignUpService: core.dataLayer.getEmailSignUpService(),
            firebaseAnalytics: core.dataLayer.getAnalytics().firebaseAnalytics
        )
    }
    
    func getDeleteAccountProgressStringsUseCase() -> GetDeleteAccountProgressStringsUseCase {
        return GetDeleteAccountProgressStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getDeleteAccountStringsUseCase() -> GetDeleteAccountStringsUseCase {
        return GetDeleteAccountStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getDeleteAccountUseCase() -> DeleteAccountUseCase {
        return DeleteAccountUseCase(
            userAuthentication: core.dataLayer.getUserAuthentication(),
            userDetailsRepository: dataLayer.getUserDetailsRepository()
        )
    }
    
    func getDidPullToRefreshAccountUseCase() -> DidPullToRefreshAccountUseCase {
        return DidPullToRefreshAccountUseCase(
            userCountersSync: core.dataLayer.getSharedUserCountersSync()
        )
    }
    
    func getLogOutUserUseCase() -> LogOutUserUseCase {
        return LogOutUserUseCase(
            userAuthentication: core.dataLayer.getUserAuthentication(),
            firebaseAnalytics: core.dataLayer.getAnalytics().firebaseAnalytics,
            userCountersRepository: core.dataLayer.getUserCountersRepository()
        )
    }
    
    func getSocialCreateAccountStringsUseCase() -> GetSocialCreateAccountStringsUseCase {
        return GetSocialCreateAccountStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getSocialSignInStringsUseCase() -> GetSocialSignInStringsUseCase {
        return GetSocialSignInStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getUserAccountDetailsUseCase() -> GetUserAccountDetailsUseCase {
        return GetUserAccountDetailsUseCase(
            userDetailsRepository: dataLayer.getUserDetailsRepository(),
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getUserIsAuthenticatedUseCase() -> GetUserIsAuthenticatedUseCase {
        return GetUserIsAuthenticatedUseCase(
            userAuthentication: core.dataLayer.getUserAuthentication()
        )
    }
}
