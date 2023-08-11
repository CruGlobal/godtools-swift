//
//  LocaleLocalizableStringsBundle.swift
//  godtools
//
//  Created by Levi Eggert on 8/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LocaleLocalizableStringsBundle: LocalizableStringsBundle {
    
    let localeBundleLoader: LocalizableStringsBundleLoader
    let locale: Locale
    let localeIdentifier: String
    
    init?(localeIdentifier: String, localeBundleLoader: LocalizableStringsBundleLoader, fileType: LocalizableStringsFileType) {
        
        self.localeBundleLoader = localeBundleLoader
        self.locale = Locale(identifier: localeIdentifier)
        self.localeIdentifier = localeIdentifier
                
        if let localeBundle = localeBundleLoader.bundleForResource(resourceName: localeIdentifier, fileType: fileType) {
            super.init(bundle: localeBundle.bundle, fileType: fileType)
        }
        else {
            return nil
        }
    }
    
    static func loadFromMainBundle(localeIdentifier: String, fileType: LocalizableStringsFileType) -> LocaleLocalizableStringsBundle? {
        
        let bundleLoader: LocalizableStringsBundleLoader = LocalizableStringsBundleLoader(localizableStringsFilesBundle: Bundle.main)
        
        return LocaleLocalizableStringsBundle(
            localeIdentifier: localeIdentifier,
            localeBundleLoader: bundleLoader,
            fileType: fileType
        )
    }
    
    override init(bundle: Bundle, fileType: LocalizableStringsFileType) {
        fatalError("init(bundle:) has not been implemented")
    }
}
