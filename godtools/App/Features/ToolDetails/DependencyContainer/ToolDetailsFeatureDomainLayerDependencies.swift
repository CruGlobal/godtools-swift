//
//  ToolDetailsFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolDetailsFeatureDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let coreDomainLayer: AppDomainLayerDependencies
    private let dataLayer: ToolDetailsFeatureDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies, dataLayer: ToolDetailsFeatureDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.coreDomainLayer = coreDomainLayer
        self.dataLayer = dataLayer
    }
    
    func getToolDetailsLearnToShareToolIsAvailableUseCase() -> GetToolDetailsLearnToShareToolIsAvailableUseCase {
        return GetToolDetailsLearnToShareToolIsAvailableUseCase(
            getToolDetailsLearnToShareToolIsAvailableRepository: dataLayer.getToolDetailsLearnToShareToolIsAvailableRepository()
        )
    }
    
    func getToolDetailsMediaUseCase() -> GetToolDetailsMediaUseCase {
        return GetToolDetailsMediaUseCase(
            getToolDetailsMediaRepository: dataLayer.getToolDetailsMediaRepository()
        )
    }

    func getViewToolDetailsUseCase() -> ViewToolDetailsUseCase {
        return ViewToolDetailsUseCase(
            getInterfaceStringsRepository: dataLayer.getToolDetailsInterfaceStringsRepository(),
            getToolDetailsRepository: dataLayer.getToolDetailsRepository()
        )
    }
}
