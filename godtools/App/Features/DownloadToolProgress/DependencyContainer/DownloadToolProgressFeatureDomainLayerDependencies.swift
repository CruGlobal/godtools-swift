//
//  DownloadToolProgressFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class DownloadToolProgressFeatureDomainLayerDependencies {
    
    private let dataLayer: DownloadToolProgressFeatureDataLayerDependencies
    
    init(dataLayer: DownloadToolProgressFeatureDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getDownloadToolProgressInterfaceStringsUseCase() -> GetDownloadToolProgressInterfaceStringsUseCase {
        return GetDownloadToolProgressInterfaceStringsUseCase(
            getInterfaceStringsRepositoryInterface: dataLayer.getDownloadToolProgressInterfaceStringsRepositoryInterface()
        )
    }
}
