//
//  TutorialDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class TutorialDiContainer: Sendable {
    
    let dataLayer: TutorialDataLayerDependencies
    let domainLayer: TutorialDomainLayerDependencies
    
    init(dataLayer: TutorialDataLayerDependencies, domainLayer: TutorialDomainLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
