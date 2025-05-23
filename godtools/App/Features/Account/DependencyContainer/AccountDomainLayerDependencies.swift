//
//  AccountDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AccountDomainLayerDependencies {
    
    private let dataLayer: AccountDataLayerDependencies
    private let coreDataLayer: AppDataLayerDependencies
    
    init(dataLayer: AccountDataLayerDependencies, coreDataLayer: AppDataLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.coreDataLayer = coreDataLayer
    }
    
    func getAuthenticateUserUseCase() -> AuthenticateUserUseCase {
        return AuthenticateUserUseCase(
            authenticateUser: dataLayer.getAuthenticateUserInterface(),
            emailSignUpService: coreDataLayer.getEmailSignUpService(),
            firebaseAnalytics: coreDataLayer.getAnalytics().firebaseAnalytics
        )
    }
    
    func getDeleteAccountUseCase() -> DeleteAccountUseCase {
        return DeleteAccountUseCase(
            userAuthentication: coreDataLayer.getUserAuthentication(),
            deleteUserDetails: dataLayer.getDeleteUserDetails()
        )
    }
    
    func getSocialCreateAccountInterfaceStringsUseCase() -> GetSocialCreateAccountInterfaceStringsUseCase {
        return GetSocialCreateAccountInterfaceStringsUseCase(
            getInterfaceStringsRepositoryInterface: dataLayer.getSocialCreateAccountInterfaceStringsRepositoryInterface()
        )
    }
    
    func getSocialSignInInterfaceStringsUseCase() -> GetSocialSignInInterfaceStringsUseCase {
        return GetSocialSignInInterfaceStringsUseCase(
            getInterfaceStringsRepositoryInterface: dataLayer.getSocialSignInInterfaceStringsRepositoryInterface()
        )
    }
    
    func getViewDeleteAccountUseCase() -> ViewDeleteAccountUseCase {
        return ViewDeleteAccountUseCase(
            getInterfaceStringsRepository: dataLayer.getDeleteAccountInterfaceStringsRepository()
        )
    }
    
    func getViewDeleteAccountProgressUseCase() -> ViewDeleteAccountProgressUseCase {
        return ViewDeleteAccountProgressUseCase(
            getInterfaceStringsRepository: dataLayer.getDeleteAccountProgressInterfaceStringsRepository()
        )
    }
}
