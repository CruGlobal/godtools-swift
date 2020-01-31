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
    
    var isEnglish: Bool {
        let languageCode: String? = NSLocale.current.languageCode
        return languageCode == "en" || languageCode == "en_US"
    }
}
