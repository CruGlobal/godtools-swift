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
    private let appLanguageFeatureDiContainer: AppLanguageFeatureDiContainer
    private let coreDataLayer: AppDataLayerDependencies
    
    init(dataLayer: ToolDetailsFeatureDataLayerDependencies, appLanguageFeatureDiContainer: AppLanguageFeatureDiContainer, coreDataLayer: AppDataLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.appLanguageFeatureDiContainer = appLanguageFeatureDiContainer
        self.coreDataLayer = coreDataLayer
    }
    
    func getToolDetailsInterfaceStringsInToolLanguageUseCase() -> GetToolDetailsInterfaceStringsInToolLanguageUseCase {
        return GetToolDetailsInterfaceStringsInToolLanguageUseCase(
            getInterfaceStringForLanguageRepositoryInterface: coreDataLayer.getInterfaceStringForLanguageRepositoryInterface()
        )
    }
    
    func getToolDetailsInToolLanguageUseCase() -> GetToolDetailsInToolLanguageUseCase {
        return GetToolDetailsInToolLanguageUseCase(
            getToolDetailsRepositoryInterface: dataLayer.getToolDetailsRepositoryInterface()
        )
    }
}
