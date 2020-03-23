//
//  TutorialToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TutorialToolsViewModel {
        
    let imageName: String
    
    required init(deviceLanguage: DeviceLanguageType) {
        
        imageName = deviceLanguage.isEnglish ? ImageCatalog.tutorialToolEnglish.name : ImageCatalog.tutorialToolNonEnglish.name
    }
}
