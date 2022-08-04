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
    
    @available(*, deprecated) // This should be removed once AttachmentsFileCache is removed and that logic placed in this class. ~Levi
    func storeFile(location: FileCacheLocation, fileData: Data) -> Result<URL, Error> {
        return fileCache.storeFile(location: location, data: fileData)
    }
    
    @available(*, deprecated) // This can be removed after removing TranslationsFileCache in place of TranslationsRepository in GT-1448. ~Levi
    func decompressZipFileAndStoreFileContents(zipFileData: Data) -> Result<[FileCacheLocation], Error> {
        
        return fileCache.decompressZipFileAndStoreFileContents(zipFileData: zipFileData)
    }
    
    // MARK: - Attachment Files
    
    func storeAttachmentFile(attachmentId: String, fileName: String, fileData: Data) -> AnyPublisher<FileCacheLocation, Error> {
        
        let fileCacheLocation: FileCacheLocation = FileCacheLocation(relativeUrlString: fileName)
        
        return Just(fileCacheLocation).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func createStoredFileRelationshipsToAttachment(attachmentId: String, location: FileCacheLocation) -> AnyPublisher<FileCacheLocation, Error> {
           
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
                        
                        promise(.success(location))
                    }
                }
                catch let error {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Translation Files
    
    func storeTranslationFile(translationId: String, fileName: String, fileData: Data) -> AnyPublisher<FileCacheLocation, Error> {
                
        let fileCacheLocation: FileCacheLocation = FileCacheLocation(relativeUrlString: fileName)
        
        return createStoredFileRelationshipsToTranslationPublisher(translationId: translationId, fileCacheLocations: [fileCacheLocation])
            .flatMap({ fileCacheLocations -> AnyPublisher<URL, Error> in
                
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
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func createStoredFileRelationshipsToTranslationPublisher(translationId: String, fileCacheLocations: [FileCacheLocation]) -> AnyPublisher<[FileCacheLocation], Error> {
        
        return Future() { promise in
            
            self.createStoredFileRelationshipsToTranslation(translationId: translationId, fileCacheLocations: fileCacheLocations) { (error: Error?) in
                
                if let error = error {
                    promise(.failure(error))
                }
                else {
                    promise(.success(fileCacheLocations))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func createStoredFileRelationshipsToTranslation(translationId: String, fileCacheLocations: [FileCacheLocation], completion: @escaping ((_ error: Error?) -> Void)) {
        
        realmDatabase.background { (realm: Realm) in
            
            guard let realmTranslation = realm.object(ofType: RealmTranslation.self, forPrimaryKey: translationId) else {
                
                let error: Error = NSError.errorWithDescription(description: "Failed to create file relationships because a translation object does not exist in realm.")
                
                completion(error)
               
                return
            }
            
            let error: Error?
            
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
                
                error = nil
            }
            catch let writeError {
                
                error = writeError
            }
            
            completion(error)
        }
    }
    
    // MARK: - Deleting Outdated Files
    
    func deleteUnusedSHA256ResourceFiles(realm: Realm) -> [Error] {
        
        // TODO: Implement in GT-1448. ~Levi
        
        assertionFailure("Implement in GT-1448.")
        return []
        
        /*
        var errors: [Error] = Array()
        
        let query: String = "attachments.@count = 0 AND translations.@count = 0"
        let realmSHA256FilesToDelete: [RealmSHA256File] = Array(realm.objects(RealmSHA256File.self).filter(query))
           
        for file in realmSHA256FilesToDelete {
    
            let error: Error? = removeFile(location: file.location)
            
            if let error = error {
                errors.append(error)
            }
        }
        
        guard !realmSHA256FilesToDelete.isEmpty else {
            return errors
        }
        
        do {
            try realm.write {
                realm.delete(realmSHA256FilesToDelete)
            }
        }
        catch let error {
            errors.append(error)
        }
        
        return errors*/
    }
}
