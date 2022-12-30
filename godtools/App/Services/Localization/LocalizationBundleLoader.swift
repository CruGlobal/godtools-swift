//
//  LocalizationBundleLoader.swift
//  godtools
//
//  Created by Levi Eggert on 10/6/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LocalizationBundleLoader {
        
    static let englishLocalizableStringsFile: String = "Base"
    
    required init() {
        
    }
    
    var englishBundle: Bundle? {
        
        if let englishBundle = bundleForResource(resourceName: LocalizationBundleLoader.englishLocalizableStringsFile) {
            return englishBundle
        }
        return nil
    }
    
    func bundleForResource(resourceName: String) -> Bundle? {
        
        guard !resourceName.isEmpty else {
            return nil
        }
        
        let localizableStringsFilename: String
        
        if resourceName == "en" || resourceName == LocalizationBundleLoader.englishLocalizableStringsFile.lowercased() {
            localizableStringsFilename = LocalizationBundleLoader.englishLocalizableStringsFile
        }
        else {
            localizableStringsFilename = resourceName
        }
        
        if !resourceName.isEmpty, let path = Bundle.main.path(forResource: localizableStringsFilename, ofType: "lproj"), let bundle: Bundle = Bundle(path: path) {
            return bundle
        }
                
        return nil
    }
}
