//
//  LearnToShareToolDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class LearnToShareToolDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: LearnToShareToolDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: LearnToShareToolDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getLearnToShareToolStringsUseCase() -> GetLearnToShareToolStringsUseCase {
        return GetLearnToShareToolStringsUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getLearnToShareToolTutorialUseCase() -> GetLearnToShareToolTutorialUseCase {
        return GetLearnToShareToolTutorialUseCase(
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
}
