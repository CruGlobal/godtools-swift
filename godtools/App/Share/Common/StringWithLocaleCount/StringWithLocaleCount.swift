//
//  StringWithLocaleCount.swift
//  godtools
//
//  Created by Levi Eggert on 7/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class StringWithLocaleCount: StringWithLocaleCountInterface {
    
    init() {
        
    }
    
    func getString(format: String, locale: Locale, count: Int) -> String {
        
        let stringWithLocaleCount = String(format: format, locale: locale, count)
        
        return stringWithLocaleCount
    }
}
