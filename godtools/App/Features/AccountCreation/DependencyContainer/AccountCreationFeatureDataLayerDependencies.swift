//
//  AccountCreationFeatureDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import SocialAuthentication

class AccountCreationFeatureDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    private func getAppleAuthentication() -> AppleAuthentication {
        return AppleAuthentication(
            appleUserPersistentStore: AppleUserPersistentStore()
        )
    }
    
    private func getFacebookAuthentication() -> FacebookAuthentication {
        return FacebookAuthentication(configuration: FacebookAuthenticationConfiguration(permissions: ["email"]))
    }
    
    private func getGoogleAuthentication() -> GoogleAuthentication {
        return GoogleAuthentication(
            configuration: coreDataLayer.getAppConfig().getGoogleAuthenticationConfiguration()
        )
    }
    
    private func getLastAuthenticatedProviderCache() -> LastAuthenticatedProviderCache {
        return LastAuthenticatedProviderCache(userDefaultsCache: coreDataLayer.getSharedUserDefaultsCache())
    }
    
    private func getUserAuthentication() -> UserAuthentication {
        return UserAuthentication(
            authenticationProviders: [
                .apple: getAppleAuthentication(),
                .facebook: getFacebookAuthentication(),
                .google: getGoogleAuthentication()
            ],
            lastAuthenticatedProviderCache: getLastAuthenticatedProviderCache(),
            mobileContentAuthTokenRepository: coreDataLayer.getMobileContentAuthTokenRepository()
        )
    }
    
    // MARK: - Domain Interface
    
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
}
