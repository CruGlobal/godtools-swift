//
//  AppLanguageDataModel+TranslatableLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 12/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension AppLanguageDataModel: TranslatableLanguage {
    
    var localeId: BCP47LanguageIdentifier {
        return languageId
    }
    
    var regionCode: String? {
        return nil
    }
    
    var scriptCode: String? {
        return languageScriptCode
    }
    
    var fallbackName: String {
        return ""
    }
}
