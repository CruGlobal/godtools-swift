//
//  MenuDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

class MenuDomainLayerDependencies {
    
    private let dataLayer: MenuDataLayerDependencies
    
    init(dataLayer: MenuDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getMenuInterfaceStringsUseCase() -> GetMenuInterfaceStringsUseCase {
        return GetMenuInterfaceStringsUseCase(
            getInterfaceStringsRepositoryInterface: dataLayer.getMenuInterfaceStringsRepository()
        )
    }
}
