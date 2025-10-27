//
//  ShareToolDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class ShareToolDomainLayerDependencies {
    
    private let domainInterfaceLayer: ShareToolDomainInterfaceDependencies
    
    init(domainInterfaceLayer: ShareToolDomainInterfaceDependencies) {
        
        self.domainInterfaceLayer = domainInterfaceLayer
    }
    
    func getViewShareToolUseCase() -> ViewShareToolUseCase {
        return ViewShareToolUseCase(
            getInterfaceStringsRepository: domainInterfaceLayer.getShareToolInterfaceStringsRepositoryInterface()
        )
    }
}
