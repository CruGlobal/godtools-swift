//
//  LearnToShareToolDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LearnToShareToolDomainLayerDependencies {
    
    private let dataLayer: LearnToShareToolDataLayerDependencies
    
    init(dataLayer: LearnToShareToolDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getViewLearnToShareToolUseCase() -> ViewLearnToShareToolUseCase {
        return ViewLearnToShareToolUseCase(
            getInterfaceStringsRepository: dataLayer.getLearnToShareToolInterfaceStringsRepositoryInterface(),
            getTutorialItemsRepository: dataLayer.getLearnToShareToolTutorialItemsRepositoryInterface()
        )
    }
}
