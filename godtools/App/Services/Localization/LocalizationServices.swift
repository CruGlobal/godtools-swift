//
//  LocalizationServices.swift
//  godtools
//
//  Created by Levi Eggert on 6/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LocalizationServices {
    
    private var englishLocalizableStrings: LocalizableStringsBundle?
    private var lastLocaleLocalizableStrings: LocaleLocalizableStringsBundle?
    private var systemLocalizableStrings: LocaleLocalizableStringsBundle?
    
    let bundleLoader: LocalizableStringsBundleLoader
    
    init(localizableStringsFilesBundle: Bundle?) {
        
        self.bundleLoader = LocalizableStringsBundleLoader(localizableStringsFilesBundle: localizableStringsFilesBundle)
    }
    
    func stringForLocaleElseSystem(localeIdentifier: String?, key: String, fileType: LocalizableStringsFileType = .strings) -> String {
        
        if let localeIdentifier = localeIdentifier, !localeIdentifier.isEmpty, let stringForLocale = getLocaleLocalizedString(localeIdentifier: localeIdentifier, key: key, fileType: fileType) {
            
            return stringForLocale
        }
        else if let stringForSytem = getSystemLocalizedString(key: key, fileType: fileType) {
            
            return stringForSytem
        }
        else if let englishString = getEnglishLocalizedString(key: key, fileType: fileType) {
            
            return englishString
        }
        else {
            
            return key
        }
    }
    
    func stringForMainBundle(key: String, fileType: LocalizableStringsFileType = .strings) -> String {
        
        if let stringForSytem = getSystemLocalizedString(key: key, fileType: fileType) {
            
            return stringForSytem
        }
        else if let englishString = getEnglishLocalizedString(key: key, fileType: fileType) {
            
            return englishString
        }
        else {
            
            return key
        }
    }
    
    func stringForBundle(bundle: Bundle, key: String, fileType: LocalizableStringsFileType = .strings) -> String {
        
        var bundleOrder: [Bundle] = [bundle]
        
        if let englishBundle = bundleLoader.getEnglishBundle(fileType: fileType)?.bundle {
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
    
    // TODO: Move into UseCase so tool_category_ logic doesn't live in data layer class. ~Levi
    func toolCategoryStringForBundle(bundle: Bundle, category: String) -> String {
        
        return stringForBundle(bundle: bundle, key: "tool_category_\(category)", fileType: .strings)
    }
    
    // TODO: Move into UseCase so tool_category_ logic doesn't live in data layer class. ~Levi
    func toolCategoryStringForLocale(localeIdentifier: String?, category: String) -> String {
        
        return stringForLocaleElseSystem(localeIdentifier: localeIdentifier, key: "tool_category_\(category)", fileType: .strings)
    }
}

// MARK: - Locale Identifier Localization

extension LocalizationServices {
    
    func getLocaleStringsBundle(localeIdentifier: String, fileType: LocalizableStringsFileType) -> LocalizableStringsBundle? {
                
        if let lastLocaleLocalizableStrings = lastLocaleLocalizableStrings, lastLocaleLocalizableStrings.localeIdentifier.lowercased() == localeIdentifier.lowercased() {
            
            return lastLocaleLocalizableStrings
        }
        else {
            
            let localeLocalizableStringsBundle = LocaleLocalizableStringsBundle(localeIdentifier: localeIdentifier, localeBundleLoader: bundleLoader, fileType: fileType)
            lastLocaleLocalizableStrings = localeLocalizableStringsBundle
            
            return localeLocalizableStringsBundle
        }
    }
    
    func getLocaleLocalizedString(localeIdentifier: String, key: String, fileType: LocalizableStringsFileType) -> String? {
        
        return getLocaleStringsBundle(localeIdentifier: localeIdentifier, fileType: fileType)?.stringForKey(key: key)
    }
}

// MARK: - System Preferred Localization

extension LocalizationServices {
    
    private func getSystemLocaleIdentifier() -> String {
        
        let localizationFilesBundle: Bundle = bundleLoader.localizableStringsFilesBundle
        let preferredLocalizations: [String] = Bundle.preferredLocalizations(from: localizationFilesBundle.localizations, forPreferences: Locale.preferredLanguages)
        
        return preferredLocalizations.first ?? Locale.current.identifier
    }
    
    func getSystemLocalizableStringsBundle(fileType: LocalizableStringsFileType) -> LocalizableStringsBundle? {
        
        let systemLocaleIdentifier: String = getSystemLocaleIdentifier()
        let systemLocaleChanged: Bool = systemLocaleIdentifier != systemLocalizableStrings?.localeIdentifier
        
        if systemLocalizableStrings == nil || systemLocaleChanged {
            
            if let newSystemLocalizableStrings = LocaleLocalizableStringsBundle(localeIdentifier: systemLocaleIdentifier, localeBundleLoader: bundleLoader, fileType: fileType) {
                systemLocalizableStrings = newSystemLocalizableStrings
            }
            else if let currentSystemLocalizableStrings = systemLocalizableStrings, currentSystemLocalizableStrings.localeIdentifier != "en" {
                systemLocalizableStrings = LocaleLocalizableStringsBundle(localeIdentifier: "en", localeBundleLoader: bundleLoader, fileType: fileType)
            }
        }
        
        return systemLocalizableStrings
    }
    
    func getSystemLocalizedString(key: String, fileType: LocalizableStringsFileType) -> String? {
        
        return getSystemLocalizableStringsBundle(fileType: fileType)?.stringForKey(key: key)
    }
}

// MARK: - English

extension LocalizationServices {
    
    func getEnglishLocalizableStringsBundle(fileType: LocalizableStringsFileType) -> LocalizableStringsBundle? {
        
        let localizableStingsBundle: LocalizableStringsBundle?
        
        if let englishLocalizableStrings = englishLocalizableStrings {
            localizableStingsBundle = englishLocalizableStrings
        }
        else if let englishBundle = bundleLoader.getEnglishBundle(fileType: fileType) {
            localizableStingsBundle = englishBundle
            englishLocalizableStrings = englishBundle
        }
        else {
            localizableStingsBundle = nil
        }
            
        return localizableStingsBundle
    }
    
    func getEnglishLocalizedString(key: String, fileType: LocalizableStringsFileType) -> String? {
        
        return getEnglishLocalizableStringsBundle(fileType: fileType)?.stringForKey(key: key)
    }
}
