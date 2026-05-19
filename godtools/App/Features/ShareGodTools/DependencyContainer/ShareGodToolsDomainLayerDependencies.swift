//
//  ShareGodToolsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class ShareGodToolsDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: ShareGodToolsDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: ShareGodToolsDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getShareGodToolsStringsUseCase() -> GetShareGodToolsStringsUseCase {
        return GetShareGodToolsStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
}
