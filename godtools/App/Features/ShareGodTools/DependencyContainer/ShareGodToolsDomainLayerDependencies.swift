//
//  ShareGodToolsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class ShareGodToolsDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: ShareGodToolsDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: ShareGodToolsDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getShareGodToolsStringsUseCase() -> GetShareGodToolsStringsUseCase {
        return GetShareGodToolsStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
