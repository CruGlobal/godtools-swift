//
//  LocaleLanguageRegionName.swift
//  godtools
//
//  Created by Levi Eggert on 12/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LocaleLanguageRegionName {
    
    init() {
        
    }
    
    func getRegionName(forRegionCode: String, translatedInLanguageId: BCP47LanguageIdentifier?) -> String? {
        
        let translateInLocale: Locale
        
        if let translatedInLanguageId = translatedInLanguageId, !translatedInLanguageId.isEmpty {
            translateInLocale = Locale(identifier: translatedInLanguageId)
        }
        else {
            translateInLocale = Locale(identifier: forRegionCode)
        }
    
        return translateInLocale.localizedString(forRegionCode: forRegionCode)
    }
}
   
