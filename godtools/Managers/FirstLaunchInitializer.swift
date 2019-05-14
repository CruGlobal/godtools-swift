 //
//  FirstLaunchInitializer.swift
//  godtools
//
//  Created by Ryan Carlson on 5/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import CoreData
import Crashlytics

class FirstLaunchInitializer: GTDataManager {
    
    let languagesManager = LanguagesManager()
    let resourceCodes = [String]() //["teachmetoshare", "kgp","satisfied","fourlaws"]
    
    func initializeAppState() {
        initializeInitialLanguages()
        initializeInitialResources()
        extractInitialZipFiles()
        saveInitialBanners()
        
        deleteLegacyFiles()
        UserDefaults.standard.set(true, forKey: GTConstants.kFirstLaunchKey)
    }
    
    private func initializeInitialLanguages() {
        languagesManager.loadInitialContentFromDisk()
        let englishLanguage = findEntity(Language.self, byAttribute: "code", withValue: "en")
        
        safelyWriteToRealm {
            englishLanguage?.shouldDownload = true
        }
        
        languagesManager.setInitialPrimaryLanguage(forceEnglish: true)
    }
    
    private func initializeInitialResources() {
        DownloadedResourceManager().loadInitialContentFromDisk()
        setResourceShouldDownload()
    }
    
    private func extractInitialZipFiles() {
        for code in resourceCodes {
            extractZipFile(resourceCode: code)
        }
    }
    
    private func extractZipFile(resourceCode: String) {
        let zipImporter = TranslationZipImporter()
        let translationsManager = TranslationsManager()
        
        let zipFileURL = fileURLForResource(code: resourceCode)
        guard let translation = translationsManager.loadTranslation(resourceCode: resourceCode,
                                                              languageCode: "en",
                                                              published: true) else { return }

        guard let zippedData = try? Data(contentsOf: zipFileURL) else { return }
        zipImporter.handleZippedData(zipData: zippedData, translation: translation)
        
        safelyWriteToRealm {
            translation.isDownloaded = true
        }
    }
    
    private func saveInitialBanners() {
        let bannerManager = BannerManager()
        
        // "id" : "475", d82d31a50fbdc0933a0a9ef4c67a3854bf70ae2e1b27738aa13fc228169552d7
        for code in resourceCodes {
            guard let resource = findEntity(DownloadedResource.self, byAttribute: "code", withValue: code) else { continue }
            if let homeBanner = findEntity(Attachment.self, byAttribute: "remoteId", withValue: resource.bannerRemoteId ?? "") {
                let homeBannerSHA = homeBanner.sha
                guard let homeBannerURL = Bundle.main.url(forResource: homeBannerSHA, withExtension: "png") else { continue }
                guard let homeBannerData = try? Data(contentsOf: homeBannerURL) else { continue }
                bannerManager.saveImageToDisk(homeBannerData, attachment: homeBanner)
            }
            
            if let aboutBanner = findEntity(Attachment.self, byAttribute: "remoteId", withValue: resource.aboutBannerRemoteId ?? "") {
                guard let aboutBannerURL = Bundle.main.url(forResource: aboutBanner.sha, withExtension: "png") else { continue }
                guard let aboutBannerData = try? Data(contentsOf: aboutBannerURL) else { continue }
                bannerManager.saveImageToDisk(aboutBannerData, attachment: aboutBanner)
            }
        }
    }
    
    private func fileURLForResource(code: String) -> URL {
        let pathToZip = Bundle.main.path(forResource: code, ofType: "zip")!
        let zipFileURL = URL(fileURLWithPath: pathToZip)
        return zipFileURL
    }
    
    private func setResourceShouldDownload() {
        safelyWriteToRealm {
            for resourceCode in resourceCodes {
                let resource = findEntity(DownloadedResource.self, byAttribute: "code", withValue: resourceCode)
                resource?.shouldDownload = true
            }
        }
    }
    
    private func deleteLegacyFiles() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsURL = URL(fileURLWithPath: documentsPath)
        let legacyFilesFolder = documentsURL.appendingPathComponent("Packages", isDirectory: true)
        
        do {
            try FileManager.default.removeItem(at: legacyFilesFolder)
        } catch {
            Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error removing legacy files folder."])
        }
    }
}
