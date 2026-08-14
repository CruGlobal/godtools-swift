//
//  ToolScreenShareDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ToolScreenShareDiContainer: Sendable {
    
    let dataLayer: ToolScreenShareDataLayerDependencies
    let domainLayer: ToolScreenShareDomainLayerDependencies
    
    init(dataLayer: ToolScreenShareDataLayerDependencies, domainLayer: ToolScreenShareDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
