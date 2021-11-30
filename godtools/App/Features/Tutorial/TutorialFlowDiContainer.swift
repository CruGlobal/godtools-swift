//
//  TutorialFlowDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/22/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class TutorialFlowDiContainer {
    
    private let appDiContainer: AppDiContainer
    
    required init(appDiContainer: AppDiContainer) {
        
        self.appDiContainer = appDiContainer
    }
    
    func getTutorialUseCase() -> GetTutorialUseCase {
        
        return GetTutorialUseCase(
            localizationServices: appDiContainer.localizationServices,
            deviceLanguage: appDiContainer.deviceLanguage
        )
    }
}
