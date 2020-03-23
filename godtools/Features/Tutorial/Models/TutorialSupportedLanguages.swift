//
//  TutorialSupportedLanguages.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TutorialSupportedLanguages: SupportedLanguagesType {
    
    let languages: [Locale]
        
    init() {
        
        languages = [
            Locale(identifier: "en"),
            Locale(identifier: "es"),
            Locale(identifier: "zh-Hans")
        ]
    }
}
