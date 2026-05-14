//
//  TutorialDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class TutorialDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: TutorialDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: TutorialDataLayerDependencies) {
        
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
