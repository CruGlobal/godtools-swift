//
//  AccountCreationFeatureDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AccountCreationFeatureDiContainer {
    
    let dataLayer: AccountCreationFeatureDataLayerDependencies
    let domainLayer: AccountCreationFeatureDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = AccountCreationFeatureDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = AccountCreationFeatureDomainLayerDependencies(dataLayer: dataLayer)
    }
}
