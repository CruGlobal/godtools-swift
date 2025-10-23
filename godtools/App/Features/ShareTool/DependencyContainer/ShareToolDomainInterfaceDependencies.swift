//
//  ShareToolDomainInterfaceDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class ShareToolDomainInterfaceDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: ShareToolDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: ShareToolDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getShareToolInterfaceStringsRepositoryInterface() -> GetShareToolInterfaceStringsRepositoryInterface {
        return GetShareToolInterfaceStringsRepository(
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            languagesRepository: coreDataLayer.getLanguagesRepository(),
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
