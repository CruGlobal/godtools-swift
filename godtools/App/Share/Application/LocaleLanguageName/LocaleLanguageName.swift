//
//  LocaleLanguageName.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LocaleLanguageName {
    
    init() {
        
    }
    
    func getDisplayName(forLanguageCode: String, translatedInLanguageId: String) -> String? {
        
        return Locale(identifier: translatedInLanguageId).localizedString(forLanguageCode: forLanguageCode)
    }
    
    func getDisplayName(forLanguageCode: String, translatedInLanguageCode: String) -> String? {
        
        return getDisplayName(forLanguageCode: forLanguageCode, translatedInLanguageId: translatedInLanguageCode)
    }
}
