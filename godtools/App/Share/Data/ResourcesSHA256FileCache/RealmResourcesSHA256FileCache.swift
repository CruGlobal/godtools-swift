//
//  RealmResourcesSHA256FileCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import RealmSwift
import SwiftUI
import UIKit

final class RealmResourcesSHA256FileCache: ResourcesSHA256FileCacheInterface {
        
    private let fileCache: ResourcesFileCache
    private let realmDatabase: RealmDatabase
    private let realmDataWrite: RealmDataWrite
    
    init(fileCache: ResourcesFileCache, realmDatabase: RealmDatabase, realmDataWrite: RealmDataWrite) {
        
        self.fileCache = fileCache
        self.realmDatabase = realmDatabase
        self.realmDataWrite = realmDataWrite
    }
    
    func getFileExists(location: FileCacheLocation) async throws -> Bool {
        return try fileCache.getFileExists(location: location)
    }
    
    func getFile(location: FileCacheLocation) async throws -> URL {
        return try fileCache.getFile(location: location)
    }
    
    func getData(location: FileCacheLocation) async throws -> Data? {
        return try fileCache.getData(location: location)
    }
    
    func getUIImage(location: FileCacheLocation) async throws -> UIImage? {
        return try fileCache.getUIImage(location: location)
    }
    
    func getImage(location: FileCacheLocation) async throws -> Image? {
        return try fileCache.getImage(location: location)
    }
        
    // MARK: - Attachment Files
    
    func storeAttachmentFile(attachmentId: String, fileName: String, fileData: Data) async throws -> FileCacheLocation {
        
        let fileCacheLocation: FileCacheLocation = FileCacheLocation(relativeUrlString: fileName)
        
        _ = try fileCache.storeFile(location: fileCacheLocation, data: fileData)
        
        _ = try await createStoredFileRelationshipsToAttachment(
            attachmentId: attachmentId,
            location: fileCacheLocation
        )
        
        return fileCacheLocation
    }

    private func createStoredFileRelationshipsToAttachment(attachmentId: String, location: FileCacheLocation) async throws -> StoreResourcesFilesResult {
        
        return try await withCheckedThrowingContinuation { continuation in
            
            realmCreateStoredFileRelationshipsToAttachmentWithCompletion(
                attachmentId: attachmentId,
                location: location,
                completion: { (result: Result<StoreResourcesFilesResult, Error>) in
                    
                    switch result {
                    case .success(let storeResourcesFilesResult):
                        continuation.resume(returning: storeResourcesFilesResult)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            )
        }
    }
    
    private func realmCreateStoredFileRelationshipsToAttachmentWithCompletion(attachmentId: String, location: FileCacheLocation, completion: @escaping ((_ result: Result<StoreResourcesFilesResult, Error>) -> Void)) {
        
        realmDataWrite.serialAsync { result in
            
            switch result {
                
            case .success(let realm):
                
                guard let filenameWithPathExtension = location.filenameWithPathExtension else {
                    let error = NSError.errorWithDescription(
                        description: "Failed to create attachment file relationships because a file with path extension does not exist."
                    )
                    completion(.failure(error))
                    return
                }
                
                guard let realmAttachment = realm.object(ofType: RealmAttachment.self, forPrimaryKey: attachmentId) else {
                    let error = NSError.errorWithDescription(
                        description: "Failed to create file relationships because an attachment object does not exist in realm."
                    )
                    completion(.failure(error))
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
                    
                    let storeResourcesFilesResult = StoreResourcesFilesResult(
                        storedFiles: [location],
                        deleteResourcesFilesResult: try self.realmDeleteUnusedResourceFiles(realm: realm)
                    )
                    
                    completion(.success(storeResourcesFilesResult))
                }
                catch let error {
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Translation Files
    
    func storeTranslationFile(translationId: String, fileName: String, fileData: Data) async throws -> FileCacheLocation {
                
        let fileCacheLocation: FileCacheLocation = FileCacheLocation(relativeUrlString: fileName)
        
        _ = try fileCache.storeFile(location: fileCacheLocation, data: fileData)
        
        _ = try await createStoredFileRelationshipsToTranslation(
            translationId: translationId,
            fileCacheLocations: [fileCacheLocation]
        )
        
        return fileCacheLocation
    }
    
    func storeTranslationZipFile(translationId: String, zipFileData: Data) async throws -> [FileCacheLocation] {
        
        let fileCacheLocations: [FileCacheLocation] = try fileCache.decompressZipFileAndStoreFileContents(zipFileData: zipFileData)
        
        _ = try await createStoredFileRelationshipsToTranslation(
            translationId: translationId,
            fileCacheLocations: fileCacheLocations
        )
        
        return fileCacheLocations
    }
    
    private func createStoredFileRelationshipsToTranslation(translationId: String, fileCacheLocations: [FileCacheLocation]) async throws -> StoreResourcesFilesResult {
        
        return try await withCheckedThrowingContinuation { continuation in
            
            realmCreateStoredFileRelationshipsToTranslationWithCompletion(
                translationId: translationId,
                fileCacheLocations: fileCacheLocations,
                completion: { (result: Result<StoreResourcesFilesResult, Error>) in
                    
                    switch result {
                    case .success(let storeResourcesFilesResult):
                        continuation.resume(returning: storeResourcesFilesResult)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            )
        }
    }
    
    private func realmCreateStoredFileRelationshipsToTranslationWithCompletion(translationId: String, fileCacheLocations: [FileCacheLocation], completion: @escaping ((_ result: Result<StoreResourcesFilesResult, Error>) -> Void)) {
        
        realmDataWrite.serialAsync { result in
            
            switch result {
            
            case .success(let realm):
                
                do {
                    
                    let storeResourcesFilesResult = try self.realmCreateStoredFileRelationshipsToTranslation(
                        realm: realm,
                        translationId: translationId,
                        fileCacheLocations: fileCacheLocations
                    )
                    
                    completion(.success(storeResourcesFilesResult))
                }
                catch let error {
                    completion(.failure(error))
                }
            
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func realmCreateStoredFileRelationshipsToTranslation(realm: Realm, translationId: String, fileCacheLocations: [FileCacheLocation]) throws -> StoreResourcesFilesResult {
            
        guard let realmTranslation = realm.object(ofType: RealmTranslation.self, forPrimaryKey: translationId) else {
            
            let error: Error = NSError.errorWithDescription(description: "Failed to create file relationships because a translation object does not exist in realm.")
            
            throw error
        }
        
        var updateSha256Files: [RealmSHA256File] = Array()
        
        for location in fileCacheLocations {
            
            guard !realmTranslation.isInvalidated else {
                updateSha256Files.removeAll()
                break
            }
            
            guard let filenameWithPathExtension = location.filenameWithPathExtension else {
                continue
            }
            
            let sha256File: RealmSHA256File
            
            if let existingRealmSHA256File = realm.object(ofType: RealmSHA256File.self, forPrimaryKey: filenameWithPathExtension), !existingRealmSHA256File.translations.contains(realmTranslation) {
                
                sha256File = existingRealmSHA256File.copy()
            }
            else {
                
                sha256File = RealmSHA256File()
                sha256File.sha256WithPathExtension = filenameWithPathExtension
            }
            
            sha256File.translations.append(realmTranslation)
            
            updateSha256Files.append(sha256File)
        }
        
        if updateSha256Files.count > 0 {
            
            try realm.write {
                
                realm.add(updateSha256Files, update: .all)
            }
        }
        
        let storeResourcesFilesResult = StoreResourcesFilesResult(
            storedFiles: fileCacheLocations,
            deleteResourcesFilesResult: try self.realmDeleteUnusedResourceFiles(realm: realm)
        )
        
        return storeResourcesFilesResult
    }
}

// MARK: - Deleting Unused Files

extension RealmResourcesSHA256FileCache {
    
    private func realmDeleteUnusedResourceFiles(realm: Realm) throws -> DeleteResourcesFilesResult {
        
        let query: String = "attachments.@count = 0 AND translations.@count = 0"
        let realmSHA256FilesToDelete: [RealmSHA256File] = Array(realm.objects(RealmSHA256File.self).filter(query))
        
        var filesToRemove: [FileCacheLocation] = Array()
        
        for file in realmSHA256FilesToDelete {
            
            let location: FileCacheLocation = FileCacheLocation(relativeUrlString: file.sha256WithPathExtension)
            
            filesToRemove.append(location)
            
            try fileCache.removeFile(location: location)
        }
        
        try realm.write {
            realm.delete(realmSHA256FilesToDelete)
        }
        
        return DeleteResourcesFilesResult(filesRemoved: filesToRemove)
    }
}
