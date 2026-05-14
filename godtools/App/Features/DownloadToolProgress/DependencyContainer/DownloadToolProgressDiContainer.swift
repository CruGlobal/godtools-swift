//
//  DownloadToolProgressDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class DownloadToolProgressDiContainer {
    
    let dataLayer: DownloadToolProgressDataLayerDependencies
    let domainLayer: DownloadToolProgressDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = DownloadToolProgressDataLayerDependencies(coreDataLayer: coreDataLayer)
        
        domainLayer = DownloadToolProgressDomainLayerDependencies(coreDataLayer: coreDataLayer, dataLayer: dataLayer)
    }
}
