//
//  AppFeatureDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AppFeatureDiContainer {
    
    let appLanguage: AppLanguageFeatureDiContainer
    
    init(appLanguage: AppLanguageFeatureDiContainer) {
        
        self.appLanguage = appLanguage
    }
}
