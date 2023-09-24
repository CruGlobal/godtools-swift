//
//  DeviceSystemLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class DeviceSystemLanguage {
    
    init() {
        
    }
    
    func getLocale() -> Locale {
        
        if let localeIdentifier = Bundle.main.preferredLocalizations.first {
            return Locale(identifier: localeIdentifier)
        }
        
        return Locale.current
    }
}
