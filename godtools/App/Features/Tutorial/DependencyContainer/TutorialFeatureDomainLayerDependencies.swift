//
//  TutorialFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class TutorialFeatureDomainLayerDependencies {
    
    private let dataLayer: TutorialFeatureDataLayerDependencies
    
    init(dataLayer: TutorialFeatureDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getTutorialUseCase() -> GetTutorialUseCase {
        return GetTutorialUseCase(
            getInterfaceStringsRepositoryInterface: dataLayer.getTutorialInterfaceStringsRepositoryInterface(),
            getTutorialRepositoryInterface: dataLayer.getTutorialRepositoryInterface()
        )
    }
}
