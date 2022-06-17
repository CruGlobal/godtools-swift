//
//  LocalizationBundleLoader.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LocalizationBundleLoader {
        
    static let EnglishLocalizableStringsFile: String = "Base"
    
    required init() {
        
    }
    
    var englishBundle: Bundle? {
        
        if let englishBundle = bundleForResource(resourceName: LocalizationBundleLoader.EnglishLocalizableStringsFile) {
            return englishBundle
        }
        return nil
    }
    
    func bundleForResource(resourceName: String) -> Bundle? {
        
        guard !resourceName.isEmpty else {
            return nil
        }
        
        let localizableStringsFilename: String
        
        if resourceName == "en" || resourceName == LocalizationBundleLoader.EnglishLocalizableStringsFile.lowercased() {
            localizableStringsFilename = LocalizationBundleLoader.EnglishLocalizableStringsFile
        }
        else {
            localizableStringsFilename = resourceName
        }
        
        if !resourceName.isEmpty, let path = Bundle.main.path(forResource: localizableStringsFilename, ofType: "lproj"), let bundle: Bundle = Bundle(path: path) {
            return bundle
        }
                
        return nil
    }
    
    func bundleForPrimaryLanguage(in languageSettingsService: LanguageSettingsService) -> Bundle? {
        guard let primaryLanguage = languageSettingsService.primaryLanguage.value else { return nil }

        return bundleForResource(resourceName: primaryLanguage.code)
    }
    
    func bundleForPrimaryLanguageOrFallback(in languageSettingsService: LanguageSettingsService) -> Bundle {
        
        return bundleForPrimaryLanguage(in: languageSettingsService) ?? englishBundle ?? Bundle.main
    }
}
