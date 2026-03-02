//
//  AccountDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AccountDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: AccountDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: AccountDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getAccountCreationIsSupportedUseCase() -> GetAccountCreationIsSupportedUseCase {
        return GetAccountCreationIsSupportedUseCase()
    }
    
    func getAccountStringsUseCase() -> GetAccountStringsUseCase {
        return GetAccountStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getAuthenticateUserUseCase() -> AuthenticateUserUseCase {
        return AuthenticateUserUseCase(
            userAuthentication: coreDataLayer.getUserAuthentication(),
            emailSignUpService: coreDataLayer.getEmailSignUpService(),
            firebaseAnalytics: coreDataLayer.getAnalytics().firebaseAnalytics
        )
    }
    
    func getDeleteAccountProgressStringsUseCase() -> GetDeleteAccountProgressStringsUseCase {
        return GetDeleteAccountProgressStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getDeleteAccountStringsUseCase() -> GetDeleteAccountStringsUseCase {
        return GetDeleteAccountStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getDeleteAccountUseCase() -> DeleteAccountUseCase {
        return DeleteAccountUseCase(
            userAuthentication: coreDataLayer.getUserAuthentication(),
            userDetailsRepository: dataLayer.getUserDetailsRepository()
        )
    }
    
    func getLogOutUserUseCase() -> LogOutUserUseCase {
        return LogOutUserUseCase(
            userAuthentication: coreDataLayer.getUserAuthentication(),
            firebaseAnalytics: coreDataLayer.getAnalytics().firebaseAnalytics,
            userCountersRepository: coreDataLayer.getUserCountersRepository()
        )
    }
    
    func getSocialCreateAccountStringsUseCase() -> GetSocialCreateAccountStringsUseCase {
        return GetSocialCreateAccountStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getSocialSignInStringsUseCase() -> GetSocialSignInStringsUseCase {
        return GetSocialSignInStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getUserAccountDetailsUseCase() -> GetUserAccountDetailsUseCase {
        return GetUserAccountDetailsUseCase(
            userDetailsRepository: dataLayer.getUserDetailsRepository(),
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getUserIsAuthenticatedUseCase() -> GetUserIsAuthenticatedUseCase {
        return GetUserIsAuthenticatedUseCase(
            userAuthentication: coreDataLayer.getUserAuthentication()
        )
    }
}
