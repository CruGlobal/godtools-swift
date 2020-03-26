//
//  TutorialInMenuViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TutorialInMenuViewModel {
    
    let imageName: String
    
    required init(deviceLanguage: DeviceLanguageType) {
        
        imageName = deviceLanguage.isEnglish ? ImageCatalog.tutorialInMenuEnglish.name : ImageCatalog.tutorialInMenuNonEnglish.name
    }
}
