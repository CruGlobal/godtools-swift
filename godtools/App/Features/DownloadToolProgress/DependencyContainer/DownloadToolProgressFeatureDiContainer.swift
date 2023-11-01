//
//  DownloadToolProgressFeatureDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class DownloadToolProgressFeatureDiContainer {
    
    let dataLayer: DownloadToolProgressFeatureDataLayerDependencies
    let domainLayer: DownloadToolProgressFeatureDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = DownloadToolProgressFeatureDataLayerDependencies(coreDataLayer: coreDataLayer)
        
        domainLayer = DownloadToolProgressFeatureDomainLayerDependencies(dataLayer: dataLayer)
    }
}
