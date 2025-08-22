//
//  ToolDetailsFeatureDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolDetailsFeatureDomainLayerDependencies {
    
    private let dataLayer: ToolDetailsFeatureDataLayerDependencies
    private let coreDataLayer: CoreDataLayerDependenciesInterface
    
    init(dataLayer: ToolDetailsFeatureDataLayerDependencies, coreDataLayer: CoreDataLayerDependenciesInterface) {
        
        self.dataLayer = dataLayer
        self.coreDataLayer = coreDataLayer
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
