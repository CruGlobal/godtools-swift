//
//  AppShortcutItemsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AppShortcutItemsDiContainer {
    
    let dataLayer: AppShortcutItemsDataLayerDependencies
    let domainLayer: AppShortcutItemsDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = AppShortcutItemsDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = AppShortcutItemsDomainLayerDependencies(dataLayer: dataLayer)
    }
}
