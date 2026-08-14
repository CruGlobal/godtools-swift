//
//  DownloadToolProgressDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class DownloadToolProgressDiContainer: Sendable {
    
    let dataLayer: DownloadToolProgressDataLayerDependencies
    let domainLayer: DownloadToolProgressDomainLayerDependencies
    
    init(dataLayer: DownloadToolProgressDataLayerDependencies, domainLayer: DownloadToolProgressDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
