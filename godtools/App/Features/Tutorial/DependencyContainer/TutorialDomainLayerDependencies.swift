//
//  TutorialDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class TutorialDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: TutorialDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: TutorialDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getTutorialIsAvailableUseCase() -> GetTutorialIsAvailableUseCase {
        return GetTutorialIsAvailableUseCase(
            getTutorialType: getTutorialType()
        )
    }
    
    func getTutorialStringsUseCase() -> GetTutorialStringsUseCase {
        return GetTutorialStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getTutorialType() -> GetTutorialType {
        return GetTutorialType()
    }
    
    func getTutorialUseCase() -> GetTutorialUseCase {
        return GetTutorialUseCase(
            localizationServices: core.dataLayer.getLocalizationServices(),
            getTutorialType: getTutorialType()
        )
    }
}
