//
//  TutorialSupportedLanguages.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TutorialSupportedLanguages: TutorialSupportedLanguagesType {
    
    let languages: [Locale]
        
    required init() {
        
        languages = [
            Locale(identifier: "en"),
            Locale(identifier: "es"),
            Locale(identifier: "zh-Hans"),
            Locale(identifier: "ru"),
            Locale(identifier: "id"),
            Locale(identifier: "fr"),
            Locale(identifier: "hi")
        ]
    }
}
