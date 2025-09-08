//
//  LanguageCodable+TranslatableLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 12/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated) // TODO: GT-1887 Remove and use LanguageDataModel. ~Levi
extension LanguageCodable: TranslatableLanguage {
    
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
