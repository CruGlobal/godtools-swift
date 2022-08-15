//
//  ResourcesSHA256FileCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine
import RealmSwift
import SwiftUI
import UIKit

class ResourcesSHA256FileCache {
    
    private static let rootDirectoryName: String = "godtools_resources_files"
    
    private let fileCache: FileCache
    private let realmDatabase: RealmDatabase
    
    init(realmDatabase: RealmDatabase) {
        
        self.fileCache = FileCache(rootDirectory: ResourcesSHA256FileCache.rootDirectoryName)
        self.realmDatabase = realmDatabase
    }
    
    func getFileExists(location: FileCacheLocation) -> Result<Bool, Error> {
        return fileCache.getFileExists(location: location)
    }
    
    func getFile(location: FileCacheLocation) -> Result<URL, Error> {
        return fileCache.getFile(location: location)
    }
    
    func getData(location: FileCacheLocation) -> Result<Data?, Error> {
        return fileCache.getData(location: location)
    }
    
    func getUIImage(location: FileCacheLocation) -> Result<UIImage?, Error> {
        return fileCache.getUIImage(location: location)
    }
    
    func getImage(location: FileCacheLocation) -> Result<Image?, Error> {
        return fileCache.getImage(location: location)
    }
        
    // MARK: - Attachment Files
    
    func storeAttachmentFile(attachmentId: String, fileName: String, fileData: Data) -> AnyPublisher<FileCacheLocation, Error> {
        
        let fileCacheLocation: FileCacheLocation = FileCacheLocation(relativeUrlString: fileName)
        
        return createStoredFileRelationshipsToAttachment(attachmentId: attachmentId, location: fileCacheLocation)
            .flatMap({ storeResourcesFilesResult -> AnyPublisher<URL, Error> in
                
                return self.fileCache.storeFile(location: fileCacheLocation, data: fileData).publisher
                    .eraseToAnyPublisher()
            })
            .flatMap({ url -> AnyPublisher<FileCacheLocation, Error> in
                
                return Just(fileCacheLocation).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func createStoredFileRelationshipsToAttachment(attachmentId: String, location: FileCacheLocation) -> AnyPublisher<StoreResourcesFilesResult, Error> {
           
        return Future() { promise in
            
            guard let filenameWithPathExtension = location.filenameWithPathExtension else {
                
                let error: Error = NSError.errorWithDescription(description: "Failed to create attachment file relationships because a file with path extension does not exist.")
                promise(.failure(error))
                return
            }
            
            self.realmDatabase.background { (realm: Realm) in
                
                guard let realmAttachment = realm.object(ofType: RealmAttachment.self, forPrimaryKey: attachmentId) else {
                    
                    let error: Error = NSError.errorWithDescription(description: "Failed to create file relationships because an attachment object does not exist in realm.")
                    promise(.failure(error))
                    return
                }
                
                do {
                    
                    try realm.write {
                        
                        if let existingRealmSHA256File = realm.object(ofType: RealmSHA256File.self, forPrimaryKey: filenameWithPathExtension), !existingRealmSHA256File.attachments.contains(realmAttachment) {
                            
                            existingRealmSHA256File.attachments.append(realmAttachment)
                        }
                        else {
                            
                            let newRealmSHA256File: RealmSHA256File = RealmSHA256File()
                            newRealmSHA256File.sha256WithPathExtension = filenameWithPathExtension
                            newRealmSHA256File.attachments.append(realmAttachment)
                            
                            realm.add(newRealmSHA256File, update: .all)
                        }
                    }
                }
                catch let writeError {
                   
                    promise(.failure(writeError))
                    
                    return
                }
                
                let storeResourcesFilesResult = StoreResourcesFilesResult(
                    storedFiles: [location],
                    deleteResourcesFilesResult: self.deleteUnusedResourceFiles(realm: realm)
                )
                
                promise(.success(storeResourcesFilesResult))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Translation Files
    
    func storeTranslationFile(translationId: String, fileName: String, fileData: Data) -> AnyPublisher<FileCacheLocation, Error> {
                
        let fileCacheLocation: FileCacheLocation = FileCacheLocation(relativeUrlString: fileName)
        
        return createStoredFileRelationshipsToTranslationPublisher(translationId: translationId, fileCacheLocations: [fileCacheLocation])
            .flatMap({ storeResourcesFilesResult -> AnyPublisher<URL, Error> in
                
                return self.fileCache.storeFile(location: fileCacheLocation, data: fileData).publisher
                    .eraseToAnyPublisher()
            })
            .flatMap({ url -> AnyPublisher<FileCacheLocation, Error> in
                
                return Just(fileCacheLocation).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func storeTranslationZipFile(translationId: String, zipFileData: Data) -> AnyPublisher<[FileCacheLocation], Error> {
        
        return fileCache.decompressZipFileAndStoreFileContentsPublisher(zipFileData: zipFileData)
            .flatMap({ fileCacheLocations -> AnyPublisher<[FileCacheLocation], Error> in
                
                return self.createStoredFileRelationshipsToTranslationPublisher(translationId: translationId, fileCacheLocations: fileCacheLocations)
                    .map { storeResourcesFilesResult in
                        return fileCacheLocations
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func createStoredFileRelationshipsToTranslationPublisher(translationId: String, fileCacheLocations: [FileCacheLocation]) -> AnyPublisher<StoreResourcesFilesResult, Error> {
        
        return Future() { promise in
            
            self.realmDatabase.background { (realm: Realm) in
                
                guard let realmTranslation = realm.object(ofType: RealmTranslation.self, forPrimaryKey: translationId) else {
                    
                    let error: Error = NSError.errorWithDescription(description: "Failed to create file relationships because a translation object does not exist in realm.")
                    
                    promise(.failure(error))
    
                    return
                }
                                
                do {
                    
                    try realm.write {

                        for location in fileCacheLocations {
                                  
                            guard let filenameWithPathExtension = location.filenameWithPathExtension else {
                                continue
                            }
                            
                            if let existingRealmSHA256File = realm.object(ofType: RealmSHA256File.self, forPrimaryKey: filenameWithPathExtension),
                               !existingRealmSHA256File.translations.contains(realmTranslation) {
                                
                                existingRealmSHA256File.translations.append(realmTranslation)
                            }
                            else {
                                
                                let newRealmSHA256File: RealmSHA256File = RealmSHA256File()
                                newRealmSHA256File.sha256WithPathExtension = filenameWithPathExtension
                                newRealmSHA256File.translations.append(realmTranslation)
                                
                                realm.add(newRealmSHA256File, update: .all)
                            }
                        }
                    }
                }
                catch let writeError {
                    
                    promise(.failure(writeError))
                    
                    return
                }
                
                let storeResourcesFilesResult = StoreResourcesFilesResult(
                    storedFiles: fileCacheLocations,
                    deleteResourcesFilesResult: self.deleteUnusedResourceFiles(realm: realm)
                )
                
                promise(.success(storeResourcesFilesResult))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Deleting Unused Files
    
    private func deleteUnusedResourceFiles(realm: Realm) -> DeleteResourcesFilesResult {
        
        let query: String = "attachments.@count = 0 AND translations.@count = 0"
        let realmSHA256FilesToDelete: [RealmSHA256File] = Array(realm.objects(RealmSHA256File.self).filter(query))
        
        var filesToRemove: [FileCacheLocation] = Array()
        var removeFileErrors: [Error] = Array()
        var writeError: Error?
        
        for file in realmSHA256FilesToDelete {
            
            let location: FileCacheLocation = FileCacheLocation(relativeUrlString: file.sha256WithPathExtension)
            
            filesToRemove.append(location)
            
            if let error = fileCache.removeFile(location: location) {
                removeFileErrors.append(error)
            }
        }
        
        do {
            try realm.write {
                realm.delete(realmSHA256FilesToDelete)
            }
        }
        catch let error {
            
            writeError = error
        }
        
        return DeleteResourcesFilesResult(filesRemoved: filesToRemove, removeFileErrors: removeFileErrors, writeError: writeError)
    }
}
