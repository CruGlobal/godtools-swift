//
//  TutorialFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class TutorialFeatureDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: TutorialFeatureDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: TutorialFeatureDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getTutorialStringsUseCase() -> GetTutorialStringsUseCase {
        return GetTutorialStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getTutorialUseCase() -> GetTutorialUseCase {
        return GetTutorialUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
