//
//  DeviceLanguagePreferences.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct DeviceLanguagePreferences: LanguagePreferencesType {
    
    init() {
        
    }
    
    var languageCode: String? {
        return NSLocale.current.languageCode
    }
    
    var isEnglish: Bool {
        return languageCode == "en" || languageCode == "en_US"
    }
}
