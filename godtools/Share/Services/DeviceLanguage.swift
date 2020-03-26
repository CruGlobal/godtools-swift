//
//  DeviceLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct DeviceLanguage: DeviceLanguageType {
    
    var languageCode: String? {
        return Locale.current.languageCode
    }
    
    var isEnglish: Bool {
        return languageCode == "en" || languageCode == "en_US"
    }
}
