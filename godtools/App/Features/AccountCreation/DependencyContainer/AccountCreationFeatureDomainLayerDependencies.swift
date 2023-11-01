//
//  AccountCreationFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AccountCreationFeatureDomainLayerDependencies {
    
    private let dataLayer: AccountCreationFeatureDataLayerDependencies
    
    init(dataLayer: AccountCreationFeatureDataLayerDependencies) {
        
        self.dataLayer = dataLayer
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
}
