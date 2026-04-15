//
//  LearnToShareToolDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LearnToShareToolDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let coreDomainLayer: AppDomainLayerDependencies
    private let dataLayer: LearnToShareToolDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies, dataLayer: LearnToShareToolDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.coreDomainLayer = coreDomainLayer
        self.dataLayer = dataLayer
    }
    
    func getLearnToShareToolStringsUseCase() -> GetLearnToShareToolStringsUseCase {
        return GetLearnToShareToolStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getLearnToShareToolTutorialUseCase() -> GetLearnToShareToolTutorialUseCase {
        return GetLearnToShareToolTutorialUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
}
