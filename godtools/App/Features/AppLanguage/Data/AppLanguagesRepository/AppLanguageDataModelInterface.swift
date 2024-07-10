//
//  AppLanguageDataModelInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

protocol AppLanguageDataModelInterface {
    
    var languageCode: String { get }
    var languageDirection: AppLanguageDataModel.Direction { get }
    var languageScriptCode: String? { get }
}

extension AppLanguageDataModelInterface {
    
    var languageId: BCP47LanguageIdentifier {
        
        if let languageScriptCode = languageScriptCode, !languageScriptCode.isEmpty {
            return languageCode + "-" + languageScriptCode
        }
        
        return languageCode
    }
}
