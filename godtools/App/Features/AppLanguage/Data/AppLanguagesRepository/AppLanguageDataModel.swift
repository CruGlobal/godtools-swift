//
//  AppLanguageDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct AppLanguageDataModel {
    
    let languageDirection: AppLanguageDataModel.Direction
    let languageId: BCP47LanguageIdentifier
    
    init(languageId: BCP47LanguageIdentifier, languageDirection: AppLanguageDataModel.Direction) {
        
        self.languageDirection = languageDirection
        self.languageId = languageId
    }
}

extension AppLanguageDataModel {
    enum Direction {
        case leftToRight
        case rightToLeft
    }
}
