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

class TranslationZipImporter {
    static let shared = TranslationZipImporter()
    
    let documentsPath: String
    let resourcesPath: String
    
    var translationDownloadQueue = [Translation]()
    
    var isProcessingQueue = false
    
    private init() {
        documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        resourcesPath = "\(documentsPath)/Resources"
        
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
    
    private func addTranslationsToQueue(_ translations: [Translation]) {
        let primaryTranslation = translations.filter( {$0.language!.isPrimary()} ).first
        if primaryTranslation != nil {
            translationDownloadQueue.append(primaryTranslation!)
        }
        
        let parallelTranslation = translations.filter( {$0.language!.isParallel()} ).first
        if (parallelTranslation != nil) {
            translationDownloadQueue.append(parallelTranslation!)
        }
        
        for translation in translations {
            if translationDownloadQueue.contains(translation) {
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

            _ = self.download(translationId: translation.remoteId!).catch(execute: { error in
                Crashlytics().recordError(error,
                                          withAdditionalUserInfo: ["customMessage": "Error downloading translation zip w/ id: \(translation.remoteId!)"])
            })
            .then(execute: { (void) -> Void in
                TranslationsManager.shared.translationWasDownloaded(translation)
            })
        }
        
        if translationDownloadQueue.count > 0 {
            processDownloadQueue()
        } else {
            isProcessingQueue = false
        }
    }
    
    private func download(translationId: String) -> Promise<Void> {
        let filename = createFilename(translationId: translationId)
        
        return downloadFromRemote(translationId: translationId).then { zipFileData -> Promise<Void> in
            
            try self.writeDataFileToDisk(data: zipFileData, filename: filename)
            self.extractZipFile(filename)
            
            return Promise(value: ())
        }.always {
            do {
                try FileManager.default.removeItem(atPath: "\(self.documentsPath)/\(filename)")
            } catch {
                Crashlytics().recordError(error,
                                          withAdditionalUserInfo: ["customMessage": "Error deleting zip file after downloading translation w/ id: \(translationId)."])
            }
        }
    }
    
    private func downloadFromRemote(translationId: String) -> Promise<Data> {
        return Alamofire.request(buildURLString(translationId: translationId))
            .downloadProgress { (progress) in
                print("Progress: \(progress.fractionCompleted * 100.0)")
            }
            .responseData()
    }
    
    private func writeDataFileToDisk(data: Data, filename: String) throws {
        try data.write(to: URL(fileURLWithPath: "\(documentsPath)/\(filename)"))
    }
    
    private func extractZipFile(_ filename: String) {
        SSZipArchive.unzipFile(atPath: "\(documentsPath)/\(filename)", toDestination: resourcesPath)
    }
    
    private func createFilename(translationId: String) -> String {
        return "\(translationId).zip"
    }
    
    private func buildURLString(translationId: String) -> String {
        return "\(GTConstants.kApiBase)/translations/\(translationId)"
        
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
