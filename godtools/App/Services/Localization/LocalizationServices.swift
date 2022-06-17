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
        
    let bundleLoader: LocalizationBundleLoader = LocalizationBundleLoader()
                 
    required init() {
            
    }
    
    func stringForLanguageElseSystem(language: LanguageModel?, key: String) -> String {
        
        if let language = language {
            
            return stringForLanguage(language: language, key: key)
        }
        
        return stringForMainBundle(key: key)
    }
    
    func stringForLanguage(language: LanguageModel, key: String) -> String {
        
        let localeLocalizationBundle: LocaleLocalizationBundle = LocaleLocalizationBundle(
            localeIdentifier: language.code,
            bundleLoader: bundleLoader
        )
        
        if let localizedStringForLanguage = localeLocalizationBundle.localeBundle?.stringForKey(key: key) {
            return localizedStringForLanguage
        }
        else if let localizedStringForBaseLanguage = localeLocalizationBundle.getBaseLanguageBundle()?.stringForKey(key: key) {
            return localizedStringForBaseLanguage
        }
        
        return stringForMainBundle(key: key)
    }
    
    func stringForMainBundle(key: String) -> String {
        
        // TODO: Would like to do some refactoring here and remove the stringForBundleOrder function because this requires that all bundles be loaded which creates more overhead. ~Levi
        // Instead, use the LocalizationBundle stringForKey method to first see if a localized string can be found and if not, load the next bundle.
        
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
            bundleOrder.append(systemBundle.bundle)
        }
        
        if let systemBaseLanguageBundle = systemLocalizationBundle.getBaseLanguageBundle() {
            bundleOrder.append(systemBaseLanguageBundle.bundle)
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
    
    func toolCategoryStringForBundle(bundle: Bundle, attrCategory: String) -> String {
        
        return stringForBundle(bundle: bundle, key: "tool_category_\(attrCategory)")
    }
}
