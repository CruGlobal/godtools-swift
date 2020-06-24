//
//  DeviceLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class DeviceLanguage: DeviceLanguageType {
        
    var languageCode: String? {
        return Locale.current.languageCode
    }
    
    var isEnglish: Bool {
        return languageCode == "en" || languageCode == "en_US"
    }
    
    func possibleLocaleCodes(locale: Locale) -> [String] {
        
        let separator: String = "-"
        var possibleLocaleCodeCombinations: [String] = Array()
        
        if let languageCode = locale.languageCode, let scriptCode = locale.scriptCode, let regionCode = locale.regionCode {
            let code: String = [languageCode, scriptCode, regionCode].joined(separator: separator)
            possibleLocaleCodeCombinations.append(code)
        }
        
        if let languageCode = locale.languageCode, let scriptCode = locale.scriptCode {
            let code: String = [languageCode, scriptCode].joined(separator: separator)
            possibleLocaleCodeCombinations.append(code)
        }
        
        if let languageCode = locale.languageCode, let regionCode = locale.regionCode {
            let code: String = [languageCode, regionCode].joined(separator: separator)
            possibleLocaleCodeCombinations.append(code)
        }
        
        if let languageCode = locale.languageCode {
            possibleLocaleCodeCombinations.append(languageCode)
        }
        
        return possibleLocaleCodeCombinations
    }
}
