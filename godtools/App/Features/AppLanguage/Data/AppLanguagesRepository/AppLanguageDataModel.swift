//
//  AppLanguageDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct AppLanguageDataModel: AppLanguageDataModelInterface {
    
    let languageCode: String
    let languageDirection: AppLanguageDataModel.Direction
    let languageScriptCode: String?
    
    init(languageCode: String, languageDirection: AppLanguageDataModel.Direction, languageScriptCode: String?) {
        
        self.languageCode = languageCode
        self.languageDirection = languageDirection
        self.languageScriptCode = languageScriptCode
    }
    
    init(interface: AppLanguageDataModelInterface) {
        
        self.languageCode = interface.languageCode
        self.languageDirection = interface.languageDirection
        self.languageScriptCode = interface.languageScriptCode
    }
}

extension AppLanguageDataModel {
    enum Direction {
        case leftToRight
        case rightToLeft
    }
}
