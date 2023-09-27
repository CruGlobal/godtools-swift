//
//  AppLanguagesRepository.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class AppLanguagesRepository {
    
    init() {
        
    }
    
    func getLanguages() -> [AppLanguageDataModel] {
        
        let appLanguages: [AppLanguageDataModel] = [
            AppLanguageDataModel(direction: .rightToLeft, languageCode: "ar"),
            AppLanguageDataModel(direction: .leftToRight, languageCode: "en"),
            AppLanguageDataModel(direction: .leftToRight, languageCode: "es")
        ]
        
        return appLanguages
    }
}
