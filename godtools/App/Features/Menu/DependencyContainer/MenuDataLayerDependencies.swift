//
//  MenuDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

class MenuDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    func getMenuInterfaceStringsRepository() -> GetMenuInterfaceStringsRepositoryInterface {
        return GetMenuInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices(),
            infoPlist: coreDataLayer.getInfoPlist()
        )
    }
}
