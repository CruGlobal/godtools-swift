//
//  LocalizationServices.swift
//  godtools
//
//  Created by Levi Eggert on 6/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LocalizationServices {
        
    private let stringsRepositories: [LocalizableStringsFileType: LocalizableStringsRepository]
    
    let bundleLoader: LocalizableStringsBundleLoader
    
    init(localizableStringsFilesBundle: Bundle?) {
        
        self.bundleLoader = LocalizableStringsBundleLoader(localizableStringsFilesBundle: localizableStringsFilesBundle)
        
        stringsRepositories = [
            .strings: LocalizableStringsRepository(localizableStringsBundleLoader: bundleLoader, fileType: .strings),
            .stringsdict: LocalizableStringsRepository(localizableStringsBundleLoader: bundleLoader, fileType: .stringsdict)
        ]
    }
    
    func stringForEnglish(key: String, fileType: LocalizableStringsFileType = .strings) -> String {
        
        return stringsRepositories[fileType]?.stringForEnglish(key: key) ?? key
    }
    
    func stringForSystemElseEnglish(key: String, fileType: LocalizableStringsFileType = .strings) -> String {
        
        return stringsRepositories[fileType]?.stringForSystemElseEnglish(key: key) ?? key
    }
    
    func stringForLocaleElseEnglish(localeIdentifier: String?, key: String, fileType: LocalizableStringsFileType = .strings) -> String {

        return stringsRepositories[fileType]?.stringForLocaleElseEnglish(localeIdentifier: localeIdentifier, key: key) ?? key
    }
    
    func stringForLocaleElseSystemElseEnglish(localeIdentifier: String?, key: String, fileType: LocalizableStringsFileType = .strings) -> String {
        
        return stringsRepositories[fileType]?.stringForLocaleElseSystemElseEnglish(localeIdentifier: localeIdentifier, key: key) ?? key
    }
}
