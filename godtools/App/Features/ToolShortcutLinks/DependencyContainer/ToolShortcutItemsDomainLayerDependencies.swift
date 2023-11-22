//
//  AppShortcutItemsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AppShortcutItemsDomainLayerDependencies {
    
    private let dataLayer: AppShortcutItemsDataLayerDependencies
    
    init(dataLayer: AppShortcutItemsDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getToolShortcutLinksUseCase() -> GetToolShortcutLinksUseCase {
        return GetToolShortcutLinksUseCase(
            getToolShortcutLinksRepositoryInterface: dataLayer.getToolShortcutLinksRepositoryInterface()
        )
    }
}
