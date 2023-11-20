//
//  AppLanguageNameDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/16/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct AppLanguageNameDomainModel {
    
    let name: String
    
    init(languageName: String, languageScriptName: String?) {
        
        if let languageScriptName = languageScriptName, !languageScriptName.isEmpty {
            
            name = languageName + " " + "(" + languageScriptName + ")"
        }
        else {
            
            name = languageName
        }
    }
}
