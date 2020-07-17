//
//  LocalizationServices.swift
//  godtools
//
//  Created by Levi Eggert on 6/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LocalizationServices {
    
    private let shouldFallbackToMainBundleIfStringEqualsKey: Bool = true
    
    required init() {
        
    }
    
    func bundleForLanguageElseMainBundle(languageCode: String) -> Bundle {
        if !languageCode.isEmpty, let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"), let bundle: Bundle = Bundle(path: path) {
            return bundle
        }
        return Bundle.main
    }
    
    func stringForBundle(bundle: Bundle, key: String, value: String? = nil, table: String? = nil) -> String {
        
        let localizedString: String = bundle.localizedString(forKey: key, value: value, table: table)
        
        if localizedString == key && shouldFallbackToMainBundleIfStringEqualsKey {
            return string(mainBundleKey: key)
        }
        
        return localizedString
    }

    func string(mainBundleKey key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
