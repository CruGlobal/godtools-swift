//
//  TranslationZipImporter.swift
//  godtools
//
//  Created by Ryan Carlson on 5/10/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import SSZipArchive
import Crashlytics

class TranslationZipImporter: GTDataManager {
    static let shared = TranslationZipImporter()
    
    let documentsPath: String
    let resourcesPath: String
    
    var translationDownloadQueue = [Translation]()
    
    var isProcessingQueue = false
    
    private override init() {
        documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        resourcesPath = "\(documentsPath)/Resources"
        
        super.init()
        
        createResourcesDirectoryIfNecessary()
    }
    
    func download(language: Language) {
        addTranslationsToQueue(Array(language.translations!) as! [Translation])
        
        if !isProcessingQueue {
            processDownloadQueue()
        }
    }
    
    func download(resource: DownloadedResource) {
        addTranslationsToQueue(Array(resource.translations!) as! [Translation])
        
        if !isProcessingQueue {
            processDownloadQueue()
        }
    }
    
    func catchupMissedDownloads() {
        addTranslationsToQueue(TranslationsManager.shared.translationsNeedingDownloaded())
        
        if !isProcessingQueue {
            processDownloadQueue()
        }
    }
    
    private func addTranslationsToQueue(_ translations: [Translation]) {
        let primaryTranslation = translations.filter( {$0.language!.isPrimary()} ).first
        if primaryTranslation != nil && !primaryTranslation!.isDownloaded {
            translationDownloadQueue.append(primaryTranslation!)
        }
        
        let parallelTranslation = translations.filter( {$0.language!.isParallel()} ).first
        if (parallelTranslation != nil && parallelTranslation!.isDownloaded) {
            translationDownloadQueue.append(parallelTranslation!)
        }
        
        for translation in translations {
            if translationDownloadQueue.contains(translation) {
                continue
            }
            
            if translation.isDownloaded {
                continue
            }
            
            if !translation.downloadedResource!.shouldDownload {
                continue
            }
            
            if !translation.language!.shouldDownload {
                continue
            }
            
            translationDownloadQueue.append(translation)
        }
    }

    private func processDownloadQueue() {
        isProcessingQueue = true
        let localDownloadQueue = translationDownloadQueue
        
        localDownloadQueue.forEach { translation in
            guard let index = translationDownloadQueue.index(of: translation) else { return }
            translationDownloadQueue.remove(at: index)

            _ = self.download(translation: translation).catch(execute: { error in
                Crashlytics().recordError(error,
                                          withAdditionalUserInfo: ["customMessage": "Error downloading translation zip w/ id: \(translation.remoteId!)"])
            })
        }
        
        if translationDownloadQueue.count > 0 {
            processDownloadQueue()
        } else {
            isProcessingQueue = false
        }
    }
    
    private func download(translation: Translation) -> Promise<Void> {
        let translationId = translation.remoteId!
        let filename = createFilename(translationId: translationId)
        
        return downloadFromRemote(translation: translation).then { zipFileData -> Promise<Void> in
            
            try self.writeDataFileToDisk(data: zipFileData, filename: filename)
            self.extractZipFile(filename, translationId: translationId)
            
            TranslationsManager.shared.translationWasDownloaded(translation)
            TranslationsManager.shared.purgeTranslationsOlderThan(translation, saving: true)
            
            if translation.language!.isPrimary() {
                self.primaryDownloadComplete(translation: translation)
            }
            return Promise(value: ())
        }.always {
            do {
                try FileManager.default.removeItem(atPath: "\(self.documentsPath)/\(filename)")
                try FileManager.default.removeItem(atPath: "\(self.documentsPath)/\(filename.replacingOccurrences(of: ".zip", with: ""))")
            } catch {
                Crashlytics().recordError(error,
                                          withAdditionalUserInfo: ["customMessage": "Error deleting zip file after downloading translation w/ id: \(translationId)."])
            }
        }
    }
    
    private func downloadFromRemote(translation: Translation) -> Promise<Data> {
        let translationId = translation.remoteId!
        
        return Alamofire.request(buildURLString(translationId: translationId))
            .downloadProgress { (progress) in
                if !translation.language!.isPrimary() {
                    return
                }
                NotificationCenter.default.post(name: .downloadProgressViewUpdateNotification,
                                                object: nil,
                                                userInfo: [GTConstants.kDownloadProgressProgressKey: progress,
                                                           GTConstants.kDownloadProgressResourceIdKey: translation.downloadedResource!.remoteId!])                
            }
            .responseData()
    }
    
    private func writeDataFileToDisk(data: Data, filename: String) throws {
        try data.write(to: URL(fileURLWithPath: "\(documentsPath)/\(filename)"))
    }
    
    private func extractZipFile(_ filename: String, translationId: String) {
        let tempDirectoryPath = "\(documentsPath)/\(filename.replacingOccurrences(of: ".zip", with: ""))"
        do {
            try FileManager.default.createDirectory(atPath: tempDirectoryPath,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            
            SSZipArchive.unzipFile(atPath: "\(documentsPath)/\(filename)", toDestination: tempDirectoryPath)
            
            try recordReferencedFiles(directoryPath: tempDirectoryPath, translationId: translationId)
            
            try moveFilesFrom(directoryPath: tempDirectoryPath)
            saveToDisk()
        } catch {
            Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error extracting zip file \(filename)"])
            rollbackContext()
        }
    }
    
    private func recordReferencedFiles(directoryPath: String, translationId: String) throws {
        guard let translation = findEntity(Translation.self, byAttribute: "remoteId", withValue: translationId) else {
            return
        }
        
        let files = try FileManager.default.contentsOfDirectory(atPath: directoryPath)
        
        for filename in files {
            let referencedFile = findEntity(ReferencedFile.self, byAttribute: "filename", withValue: filename) ?? createEntity(ReferencedFile.self)
            referencedFile?.filename = filename
            referencedFile?.addToTranslations(translation)
        }
    }
    
    private func moveFilesFrom(directoryPath: String) throws {
        let fileManager = FileManager.default
        let files = try fileManager.contentsOfDirectory(atPath: directoryPath)

        for filename in files {
            let fullSourcePath = "\(directoryPath)/\(filename)"
            let fullDestinationPath = "\(resourcesPath)/\(filename)"
            if fileManager.fileExists(atPath: fullDestinationPath) {
                try fileManager.removeItem(atPath: fullDestinationPath)
            }
            
            try fileManager.moveItem(atPath: fullSourcePath, toPath: fullDestinationPath)
        }
    }
    
    private func createFilename(translationId: String) -> String {
        return "\(translationId).zip"
    }
    
    private func buildURLString(translationId: String) -> String {
        return "\(GTConstants.kApiBase)/translations/\(translationId)"
        
    }
    
    private func primaryDownloadComplete(translation: Translation) {
        NotificationCenter.default.post(name: .downloadPrimaryTranslationCompleteNotification,
                                        object: nil,
                                        userInfo: [GTConstants.kDownloadProgressResourceIdKey: translation.downloadedResource!.remoteId!])
    }
    
    private func createResourcesDirectoryIfNecessary() {
        if FileManager.default.fileExists(atPath: resourcesPath, isDirectory: nil) {
            return
        }
        
        do {
            try FileManager.default.createDirectory(atPath: resourcesPath,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
        } catch {
            Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error creating Resources directory on device."])
        }
    }
}
