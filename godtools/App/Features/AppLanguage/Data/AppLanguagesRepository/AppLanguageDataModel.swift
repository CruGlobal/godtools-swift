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
    
    var languageId: BCP47LanguageIdentifier {
        
        if let languageScriptCode = languageScriptCode, !languageScriptCode.isEmpty {
            return languageCode + "-" + languageScriptCode
        }
        
        return languageCode
    }
    
    init(languageCode: String, languageDirection: AppLanguageDataModel.Direction, languageScriptCode: String?) {
        
        self.languageCode = languageCode
        self.languageDirection = languageDirection
        self.languageScriptCode = languageScriptCode
    }
    
    init(realmAppLanguage: RealmAppLanguage) {
        
        self.languageCode = realmAppLanguage.languageCode
        self.languageScriptCode = realmAppLanguage.languageScriptCode
        
        switch realmAppLanguage.languageDirection {
        case .leftToRight:
            languageDirection = .leftToRight
        case .rightToLeft:
            languageDirection = .rightToLeft
        }
    }
}

extension AppLanguageDataModel {
    enum Direction {
        case leftToRight
        case rightToLeft
    }
}
