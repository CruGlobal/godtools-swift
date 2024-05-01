//
//  LocalizableStringDictKeys.swift
//  godtools
//
//  Created by Levi Eggert on 4/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

enum LocalizableStringDictKeys: String {
    
    case languageSettingsAppLanguageNumberAvailable = "languageSettings.appLanguage.numberAvailable"
}

extension LocalizableStringDictKeys {
    var key: String {
        return rawValue
    }
}
