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
import RealmSwift

class TranslationZipImporter: GTDataManager {
    
    let path = "translations"
    
    var translationDownloadQueue = [Translation]()
    
    var isProcessingQueue = false
    
    override init() {
        super.init()
        
        createResourcesDirectoryIfNecessary()
    }
    
    func download(language: Language) {
        addTranslationsToQueue(language.translations)
        
        if !isProcessingQueue {
            processDownloadQueue()
        }
    }
    
    func download(resource: DownloadedResource) {
        addTranslationsToQueue(resource.translations)
        
        if !isProcessingQueue {
            processDownloadQueue()
        }
    }

    func catchupMissedDownloads() {
        addTranslationsToQueue(TranslationsManager().translationsNeedingDownloaded())
        
        if !isProcessingQueue {
            processDownloadQueue()
        }
    }

    private func addTranslationsToQueue(_ translations: List<Translation>) {
        let translations = Array(translations)
        
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
                                          withAdditionalUserInfo: ["customMessage": "Error downloading translation zip w/ id: \(translation.remoteId)"])
            })
        }
        
        if translationDownloadQueue.count > 0 {
            processDownloadQueue()
        } else {
            isProcessingQueue = false
        }
    }
    
    private func download(translation: Translation) -> Promise<Void> {
        let translationId = translation.remoteId
        let filename = createFilename(translationId: translationId)
        
        guard let tempDirectoryPath = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID().uuidString) else {
            return Promise(value: ())
        }
        
        return downloadFromRemote(translation: translation).then { zipFileData -> Promise<Void> in

            try FileManager.default.createDirectory(at: tempDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            
            let zipFile = tempDirectoryPath.appendingPathComponent(filename)
            
            try self.writeDataFileToDisk(data: zipFileData, to: zipFile)
            self.extractZipFile(zipFile, translationId: translationId)
            
            let translationsManager = TranslationsManager()
            translationsManager.translationWasDownloaded(translation)
            translationsManager.purgeTranslationsOlderThan(translation)
            
            if translation.language!.isPrimary() {
                self.primaryDownloadComplete(translation: translation)
            }
            return Promise(value: ())
        }.always {
            do {
                try FileManager.default.removeItem(at: tempDirectoryPath)
            } catch {
                Crashlytics().recordError(error,
                                          withAdditionalUserInfo: ["customMessage": "Error deleting temporary directory after downloading translation w/ id: \(translationId)."])
            }
        }
    }
    
    private func downloadFromRemote(translation: Translation) -> Promise<Data> {
        let translationId = translation.remoteId
        
        return Alamofire.request(buildURL(translationId: translationId) ?? "")
            .downloadProgress { (progress) in
                if !translation.language!.isPrimary() {
                    return
                }
                NotificationCenter.default.post(name: .downloadProgressViewUpdateNotification,
                                                object: nil,
                                                userInfo: [GTConstants.kDownloadProgressProgressKey: progress,
                                                           GTConstants.kDownloadProgressResourceIdKey: translation.downloadedResource!.remoteId])
            }
            .responseData()
    }
    
    private func writeDataFileToDisk(data: Data, to path: URL) throws {
        try data.write(to: path)
    }
    
    private func extractZipFile(_ file: URL, translationId: String) {
        let unzipDirectory = file.deletingPathExtension()
        
        do {
            try FileManager.default.createDirectory(at: unzipDirectory,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            
            SSZipArchive.unzipFile(atPath: file.path,
                                   toDestination: unzipDirectory.path)
            
            try recordReferencedFiles(directory: unzipDirectory,
                                      translationId: translationId)
            
            try moveFilesFrom(unzipDirectory)
        } catch {
            Crashlytics().recordError(error, withAdditionalUserInfo: ["customMessage": "Error extracting zip file \(file.lastPathComponent)"])
        }
    }
    
    private func recordReferencedFiles(directory: URL, translationId: String) throws {
        guard let translation = findEntityByRemoteId(Translation.self, remoteId: translationId) else {
            return
        }
        
        let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        safelyWriteToRealm {
            for file in files {
                let filename = file.lastPathComponent
                if let referencedFile = findEntity(ReferencedFile.self, byAttribute: "filename", withValue: filename) {
                    referencedFile.translations.append(translation)
                    continue
                }
                
                let referencedFile = ReferencedFile()
                referencedFile.filename = file.lastPathComponent
                referencedFile.translations.append(translation)
                realm.add(referencedFile)
            }
        }
    }
    
    private func moveFilesFrom(_ path: URL) throws {
        let fileManager = FileManager.default
        let files = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

        for file in files {
            let destinationPath = URL(fileURLWithPath: resourcesPath.appending("/").appending(file.lastPathComponent))
            if fileManager.fileExists(atPath: destinationPath.path) {
                try fileManager.removeItem(at: destinationPath)
            }
            
            try fileManager.moveItem(at: file, to: destinationPath)
        }
    }
    
    private func createFilename(translationId: String) -> String {
        return translationId.appending(".zip")
    }
    
    private func buildURL(translationId: String) -> URL? {
        return Config.shared().baseUrl?
                              .appendingPathComponent(self.path)
                              .appendingPathComponent(translationId)
    }
    
    private func primaryDownloadComplete(translation: Translation) {
        NotificationCenter.default.post(name: .downloadPrimaryTranslationCompleteNotification,
                                        object: nil,
                                        userInfo: [GTConstants.kDownloadProgressResourceIdKey: translation.downloadedResource!.remoteId])
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
