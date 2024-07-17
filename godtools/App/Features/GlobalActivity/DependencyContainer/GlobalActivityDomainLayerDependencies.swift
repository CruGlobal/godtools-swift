//
//  GlobalActivityDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 3/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class GlobalActivityDomainLayerDependencies {
    
    private let dataLayer: GlobalActivityDataLayerDependencies
    
    init(dataLayer: GlobalActivityDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getViewGlobalActivityThisWeekUseCase() -> ViewGlobalActivityThisWeekUseCase {
        
        return ViewGlobalActivityThisWeekUseCase(
            getGlobalActivityRepository: dataLayer.getGlobalActivityThisWeekRepository()
        )
    }
}
