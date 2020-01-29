//
//  AppDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AppDiContainer {
        
    let tutorialServices: TutorialServicesType
    
    required init() {
        
        tutorialServices = TutorialServices(languagePreferences: DeviceLanguagePreferences())
    }
}
