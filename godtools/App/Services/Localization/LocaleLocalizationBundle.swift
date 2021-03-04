//
//  LocaleLocalizationBundle.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LocaleLocalizationBundle {
    
    let locale: Locale
    let bundleLoader: LocalizationBundleLoader
    let localeBundle: LocalizationBundle?
    
    required init(localeIdentifier: String, bundleLoader: LocalizationBundleLoader) {
        
        let locale: Locale = Locale(identifier: localeIdentifier)
        
        self.locale = locale
        self.bundleLoader = bundleLoader
        
        if let bundle = bundleLoader.bundleForResource(resourceName: localeIdentifier) {
            localeBundle = LocalizationBundle(bundle: bundle)
        }
        else {
            localeBundle = nil
        }
    }
    
    func getBaseLanguageBundle() -> LocalizationBundle? {
        
        guard !locale.isBaseLanguage else {
            return localeBundle
        }
        
        if let languageCode = locale.languageCode, !languageCode.isEmpty, let bundle = bundleLoader.bundleForResource(resourceName: languageCode) {
            return LocalizationBundle(bundle: bundle)
        }
        
        return nil
    }
}
