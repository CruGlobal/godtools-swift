//
//  LocalizableStringsBundleLoader.swift
//  godtools
//
//  Created by Levi Eggert on 8/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LocalizableStringsBundleLoader {
    
    // NOTE: Will be Base if Use Base Internationalization is checked in Project > Info > Localizations Section.
    //       English.lproj is deprecated for Localizable.strings. ~Levi
    static let englishLocalizableStringsFile: String = "Base"
    
    // NOTE: Stringsdict still uses deprecated English.lproj. ~Levi
    static let englishLocalizableStringsdictFile: String = "English"
    
    let localizableStringsFilesBundle: Bundle
    
    init(localizableStringsFilesBundle: Bundle?) {
        
        self.localizableStringsFilesBundle = localizableStringsFilesBundle ?? Bundle.main
    }
    
    func getEnglishBundle(fileType: LocalizableStringsFileType) -> LocalizableStringsBundle? {
        
        guard let englishBundle = bundleForResource(resourceName: "en", fileType: fileType) else {
            return nil
        }
        
        return englishBundle
    }
    
    func bundleForResource(resourceName: String, fileType: LocalizableStringsFileType) -> LocalizableStringsBundle? {
                
        guard !resourceName.isEmpty else {
            return nil
        }
        
        let possibleEnglishLocalizableStringsFiles: [String] = ["en", "english", "base"]
        let isEnglishResource: Bool = possibleEnglishLocalizableStringsFiles.contains(resourceName.lowercased())
            
        let localizationFilePath: String
        
        if isEnglishResource {
           
            switch fileType {
           
            case .strings:
                localizationFilePath = LocalizableStringsBundleLoader.englishLocalizableStringsFile
                
            case .stringsdict:
                localizationFilePath = LocalizableStringsBundleLoader.englishLocalizableStringsdictFile
            }
        }
        else {
            
            localizationFilePath = resourceName
        }
          
        guard let bundlePath = localizableStringsFilesBundle.path(forResource: localizationFilePath, ofType: "lproj") else {
            return nil
        }
        
        guard let bundle = Bundle(path: bundlePath) else {
            return nil
        }
        
     
        let localizableStringsBundle = LocalizableStringsBundle(bundle: bundle)
        
        return localizableStringsBundle
    }
}
