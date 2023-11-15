//
//  AppLanguageDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct AppLanguageDataModel {
    
    let languageCode: String
    let languageDirection: AppLanguageDataModel.Direction
    let languageId: BCP47LanguageIdentifier
    let languageScriptCode: String?
    
    init(languageId: BCP47LanguageIdentifier, languageDirection: AppLanguageDataModel.Direction) {
        
        self.languageDirection = languageDirection
        self.languageId = languageId
        
        let locale = Locale(identifier: languageId)
        let languageCode: String?
        let languageScriptCode: String?
        
        if #available(iOS 16.0, *) {
            languageCode = locale.language.languageCode?.identifier
            languageScriptCode = locale.language.script?.identifier
        }
        else {
            languageCode = locale.languageCode
            languageScriptCode = locale.scriptCode
        }
        
        self.languageCode = languageCode ?? languageId
        self.languageScriptCode = languageScriptCode
    }
}

extension AppLanguageDataModel {
    enum Direction {
        case leftToRight
        case rightToLeft
    }
}
