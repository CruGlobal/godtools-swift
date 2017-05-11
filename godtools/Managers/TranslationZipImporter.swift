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

class TranslationZipImporter {
    static let shared = TranslationZipImporter()
    
    let documentsPath: String
    let resourcesPath: String
    
    private init() {
        documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        resourcesPath = "\(documentsPath)/Resources"
        
        createResourcesDirectoryIfNecessary()
    }
    
    func download(translationId: String) -> AnyPromise {
        let filename = createFilename(translationId: translationId)
        
        let promisedDownload = downloadFromRemote(translationId: translationId).then { zipFileData -> Promise<Bool> in
            
            try self.writeDataFileToDisk(data: zipFileData, filename: filename)
            self.extractZipFile(filename)
            
            return Promise(value: true)
            }.always {
                do {
                    try FileManager.default.removeItem(atPath: "\(self.documentsPath)/\(filename)")
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
        
        return AnyPromise(promisedDownload)
    }
    
    private func downloadFromRemote(translationId: String) -> Promise<Data> {
        return Alamofire.request(buildURLString(translationId: translationId))
            .downloadProgress { (progress) in
                print("Progress: \(progress.fractionCompleted * 100.0)")
            }
            .responseData()
            .catch(execute: { (error) in
                print("Error: \(error.localizedDescription)")
            })
    }
    
    private func writeDataFileToDisk(data: Data, filename: String) throws {
        try data.write(to: URL.init(fileURLWithPath: "\(documentsPath)/\(filename)"))
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
            print(error.localizedDescription)
        }
    }
}
