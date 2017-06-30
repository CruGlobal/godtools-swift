//
//  FirstLaunchInitializer.swift
//  godtools
//
//  Created by Ryan Carlson on 5/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreData

class FirstLaunchInitializer: GTDataManager {
    
    let languagesManager = LanguagesManager()
    
    func initializeAppState() {
        initializeInitialLanguages()
        initializeInitialResources()
        extractInitialZipFiles()
    }
    
    private func initializeInitialLanguages() {
        languagesManager.loadInitialContentFromDisk()
        let englishLanguage = findEntity(Language.self, byAttribute: "code", withValue: "en")
        
        safelyWriteToRealm {
            englishLanguage?.shouldDownload = true
        }
    }
    
    private func initializeInitialResources() {
        DownloadedResourceManager().loadInitialContentFromDisk()
        setResourceShouldDownload(resourceCodes: ["kgp","sat","4sl"])
    }
    
    private func extractInitialZipFiles() {
        for code in ["kgp","sat","4sl"] {
            extractZipFile(resourceCode: code)
        }
    }
    
    private func extractZipFile(resourceCode: String) {
        let zipImporter = TranslationZipImporter()
        let translationsManager = TranslationsManager()
        
        let zipFileURL = fileURLForResource(code: resourceCode)
        let translation = translationsManager.loadTranslation(resourceCode: resourceCode,
                                                              languageCode: "en",
                                                              published: true)!

        let zippedData = try! Data(contentsOf: zipFileURL)
        zipImporter.handleZippedData(zipData: zippedData, translation: translation)
        
        safelyWriteToRealm {
            translation.isDownloaded = true
        }
    }
    
    private func fileURLForResource(code: String) -> URL {
        let pathToZip = Bundle.main.path(forResource: code, ofType: "zip")!
        let zipFileURL = URL(fileURLWithPath: pathToZip)
        return zipFileURL
    }
    
    private func setResourceShouldDownload(resourceCodes: [String]) {
        safelyWriteToRealm {
            for resourceCode in resourceCodes {
                let resource = findEntity(DownloadedResource.self, byAttribute: "code", withValue: resourceCode)
                resource?.shouldDownload = true
            }
        }
    }
}
