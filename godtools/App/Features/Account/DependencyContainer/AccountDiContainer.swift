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
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = AccountDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = AccountDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
