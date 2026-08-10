//
//  ShareGodToolsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

@MainActor
final class ShareGodToolsDiContainer {
    
    let dataLayer: ShareGodToolsDataLayerDependencies
    let domainLayer: ShareGodToolsDomainLayerDependencies
    
    init(dataLayer: ShareGodToolsDataLayerDependencies, domainLayer: ShareGodToolsDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
