//
//  LocalizationServices.swift
//  godtools
//
//  Created by Levi Eggert on 6/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LocalizationServices {
    
    private static let EnglishLocalizableStringsFile: String = "Base"
    
    private static var cachedEnglishBundle: Bundle?
    
    let bundleLoader: LocalizationBundleLoader = LocalizationBundleLoader()
                 
    required init() {
            
    }
    
    func stringForMainBundle(key: String) -> String {
        
        let systemLocaleIdentifier: String
        
        if let preferredLocalization = Bundle.main.preferredLocalizations.first {
            systemLocaleIdentifier = preferredLocalization
        }
        else {
            systemLocaleIdentifier = Locale.current.identifier
        }
        
        let systemLocalizationBundle = LocaleLocalizationBundle(
            localeIdentifier: systemLocaleIdentifier,
            bundleLoader: bundleLoader
        )
        
        var bundleOrder: [Bundle] = Array()
        
        if let systemBundle = systemLocalizationBundle.localeBundle {
            bundleOrder.append(systemBundle)
        }
        
        if let systemBaseLanguageBundle = systemLocalizationBundle.localeBaseLanguageBundle {
            bundleOrder.append(systemBaseLanguageBundle)
        }
        
        bundleOrder.append(Bundle.main)

        if let englishBundle = bundleLoader.englishBundle {
            bundleOrder.append(englishBundle)
        }
        
        return stringForBundleOrder(bundleOrder: bundleOrder, key: key)
    }
    
    func stringForBundle(bundle: Bundle, key: String) -> String {
        
        var bundleOrder: [Bundle] = [bundle]
        
        if let englishBundle = bundleLoader.englishBundle {
            bundleOrder.append(englishBundle)
        }
        
        bundleOrder.append(Bundle.main)
        
        return stringForBundleOrder(bundleOrder: bundleOrder, key: key)
    }
    
    func stringForBundleOrder(bundleOrder: [Bundle], key: String) -> String {
        
        for bundle in bundleOrder {
            
            let localizedString: String = bundle.localizedString(forKey: key, value: nil, table: nil)
            
            if !localizedString.isEmpty && localizedString != key {
                return localizedString
            }
        }
        
        return key
    }
}
