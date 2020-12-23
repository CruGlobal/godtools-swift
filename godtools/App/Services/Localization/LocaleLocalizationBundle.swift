//
//  LocaleLocalizationBundle.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LocaleLocalizationBundle {
    
    let localeBundle: Bundle?
    let localeBaseLanguageBundle: Bundle?
    
    required init(localeIdentifier: String, bundleLoader: LocalizationBundleLoader) {
        
        localeBundle = bundleLoader.bundleForResource(resourceName: localeIdentifier)
        
        let locale: Locale = Locale(identifier: localeIdentifier)
        
        if !locale.isBaseLanguage, let languageCode = locale.languageCode, !languageCode.isEmpty {
            localeBaseLanguageBundle = bundleLoader.bundleForResource(resourceName: languageCode)
        }
        else {
            localeBaseLanguageBundle = nil
        }
    }
}
