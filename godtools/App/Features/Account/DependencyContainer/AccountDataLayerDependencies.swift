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
    
    // MARK: - Domain Interface
    
    func getAuthenticateUserInterface() -> AuthenticateUserInterface {
        return AuthenticateUser(
            userAuthentication: coreDataLayer.getUserAuthentication()
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
}
