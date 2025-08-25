//
//  AccountDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/31/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AccountDiContainer {
    
    let dataLayer: AccountDataLayerDependencies
    let domainInterfaceLayer: AccountDomainInterfaceDependencies
    let domainLayer: AccountDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: AccountDataLayerDependencies, domainInterfaceLayer: AccountDomainInterfaceDependencies) {
        
        self.dataLayer = dataLayer
        self.domainInterfaceLayer = domainInterfaceLayer
        domainLayer = AccountDomainLayerDependencies(coreDataLayer: coreDataLayer, domainInterfaceLayer: domainInterfaceLayer)
    }
}
