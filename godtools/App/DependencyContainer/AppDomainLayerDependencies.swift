//
//  AppDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AppDomainLayerDependencies {
    
    private let dataLayer: AppDataLayerDependencies
    
    init(dataLayer: AppDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getToolTranslationsUseCase() -> GetToolTranslationsUseCase {
        return GetToolTranslationsUseCase(
            resourcesRepository: dataLayer.getResourcesRepository(),
            translationsRepository: dataLayer.getTranslationsRepository(),
            languagesRepository: dataLayer.getLanguagesRepository(),
            mobileContentParser: dataLayer.getMobileContentParser()
        )
    }
}
