//
//  MenuDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

class MenuDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: MenuDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: MenuDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getMenuStringsUseCase() -> GetMenuStringsUseCase {
        return GetMenuStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices(),
            infoPlist: coreDataLayer.getInfoPlist()
        )
    }
}
