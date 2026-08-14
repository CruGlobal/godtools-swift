//
//  LearnToShareToolDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class LearnToShareToolDiContainer: Sendable {
    
    let dataLayer: LearnToShareToolDataLayerDependencies
    let domainLayer: LearnToShareToolDomainLayerDependencies
    
    init(dataLayer: LearnToShareToolDataLayerDependencies, domainLayer: LearnToShareToolDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
