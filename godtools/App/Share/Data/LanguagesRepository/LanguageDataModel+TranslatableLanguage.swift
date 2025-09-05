//
//  LanguageDataModel+TranslatableLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

extension LanguageDataModel: TranslatableLanguage {
    
    var localeId: BCP47LanguageIdentifier {
        return code
    }
    
    var languageCode: String {
            
        return code.languageCode
    }
    
    var regionCode: String? {
        
        return code.regionCode
    }
    
    var scriptCode: String? {
        
        return code.scriptCode
    }
    
    var fallbackName: String {
        return name
    }
}
