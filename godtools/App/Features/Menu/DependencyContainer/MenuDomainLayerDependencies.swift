//
//  MenuDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class MenuDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: MenuDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: MenuDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getMenuStringsUseCase() -> GetMenuStringsUseCase {
        return GetMenuStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices(),
            infoPlist: core.dataLayer.getInfoPlist()
        )
    }
}
