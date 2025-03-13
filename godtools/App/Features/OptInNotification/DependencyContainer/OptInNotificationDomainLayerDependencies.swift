//
//  OptInNotificationDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class OptInNotificationDomainLayerDependencies {
    
    private let dataLayer: OptInNotificationDataLayerDependencies
    
    init(dataLayer: OptInNotificationDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getViewOptInNotificationsUseCase() -> ViewOptInNotificationsUseCase {
        return ViewOptInNotificationsUseCase(
            getInterfaceStringsRepository: dataLayer.getInterfaceStringsRepositoryInterface()
        )
    }
  
}
