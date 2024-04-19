//
//  ShareGodToolsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class ShareGodToolsDomainLayerDependencies {
    
    private let dataLayer: ShareGodToolsDataLayerDependencies
    
    init(dataLayer: ShareGodToolsDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getViewShareGodToolsUseCase() -> ViewShareGodToolsUseCase {
        return ViewShareGodToolsUseCase(
            getInterfaceStringsRepository: dataLayer.getShareGodToolsInterfaceStringsRepository()
        )
    }
}
