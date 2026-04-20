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
    let languageScriptCode: String?
}

extension AppLanguageDataModel {
    enum Direction {
        case leftToRight
        case rightToLeft
    }
}

extension AppLanguageDataModel {
    var languageId: BCP47LanguageIdentifier {
        
        if let languageScriptCode = languageScriptCode, !languageScriptCode.isEmpty {
            return languageCode + "-" + languageScriptCode
        }
        
        return languageCode
    }
}
