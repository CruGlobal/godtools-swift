//
//  AccountDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class AccountDiContainer {
    
    let dataLayer: AccountDataLayerDependencies
    let domainLayer: AccountDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = AccountDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = AccountDomainLayerDependencies(coreDataLayer: coreDataLayer, dataLayer: dataLayer)
    }
}
