//
//  ResourcesSHA256FileCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import SwiftData
import SwiftUI
import UIKit

@available(iOS 17.4, *)
actor ResourcesSHA256FileCache: ResourcesSHA256FileCacheInterface, ModelActor {
        
    private let resourcesFileCache: ResourcesFileCache
    
    let modelContainer: ModelContainer
    let modelExecutor: ModelExecutor
    
    init(container: ModelContainer, resourcesFileCache: ResourcesFileCache) {
        
        self.resourcesFileCache = resourcesFileCache
        
        self.modelContainer = container
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(container))
    }
    
    func getFileExists(location: FileCacheLocation) async throws -> Bool {
        return try await resourcesFileCache.cache.getFileExists(location: location)
    }
    
    func getFile(location: FileCacheLocation) async throws -> URL {
        return try await resourcesFileCache.cache.getFile(location: location)
    }
    
    func getData(location: FileCacheLocation) async throws -> Data? {
        return try await resourcesFileCache.cache.getData(location: location)
    }
    
    func getUIImage(location: FileCacheLocation) async throws -> UIImage? {
        return try await resourcesFileCache.cache.getUIImage(location: location)
    }
    
    func getImage(location: FileCacheLocation) async throws -> Image? {
        return try await resourcesFileCache.cache.getImage(location: location)
    }
        
    // MARK: - Attachment Files
    
    func storeAttachmentFile(attachmentId: String, fileName: String, fileData: Data) async throws -> FileCacheLocation {
        
        let fileCacheLocation: FileCacheLocation = FileCacheLocation(relativeUrlString: fileName)
        
        _ = try await resourcesFileCache.cache.storeFile(location: fileCacheLocation, data: fileData)
        
        _ = try await createStoredFileRelationshipsToAttachment(
            attachmentId: attachmentId,
            location: fileCacheLocation
        )
        
        return fileCacheLocation
    }

    private func createStoredFileRelationshipsToAttachment(
        attachmentId: String,
        location: FileCacheLocation
    ) async throws -> StoreResourcesFilesResult {
        
        guard let filenameWithPathExtension = location.filenameWithPathExtension else {
            throw NSError.errorWithDescription(
                description: "Failed to create attachment file relationships because a file with path extension does not exist."
            )
        }
        
        let swiftDataRead = SwiftDataRead()
        
        let attachment: SwiftAttachment? = try swiftDataRead.object(context: modelContext, id: attachmentId)
        
        guard let attachment = attachment else {
            throw NSError.errorWithDescription(
                description: "Failed to create file relationships because an attachment object does not exist in the database."
            )
        }
        
        let existing: SwiftSHA256File? = try swiftDataRead.object(context: modelContext, id: filenameWithPathExtension)

        if let existing = existing {

            if !existing.attachments.contains(attachment) {
                existing.attachments.append(attachment)
            }
        }
        else {

            let sha256File = SwiftSHA256File()
            sha256File.id = filenameWithPathExtension
            sha256File.sha256WithPathExtension = filenameWithPathExtension
            sha256File.attachments.append(attachment)

            modelContext.insert(sha256File)
        }

        try modelContext.saveIfHasChanges()
        
        let deleteResourcesFilesResult = try await deleteUnusedResourceFiles()
        
        return StoreResourcesFilesResult(
            storedFiles: [location],
            deleteResourcesFilesResult: deleteResourcesFilesResult
        )
    }
    
    // MARK: - Translation Files
    
    func storeTranslationFile(translationId: String, fileName: String, fileData: Data) async throws -> FileCacheLocation {
                
        let fileCacheLocation: FileCacheLocation = FileCacheLocation(relativeUrlString: fileName)
        
        _ = try await resourcesFileCache.cache.storeFile(location: fileCacheLocation, data: fileData)
        
        _ = try await createStoredFileRelationshipsToTranslation(
            translationId: translationId,
            fileCacheLocations: [fileCacheLocation]
        )
        
        return fileCacheLocation
    }
    
    func storeTranslationZipFile(translationId: String, zipFileData: Data) async throws -> [FileCacheLocation] {
        
        let fileCacheLocations: [FileCacheLocation] = try await resourcesFileCache.cache.decompressZipFileAndStoreFileContents(zipFileData: zipFileData)
        
        _ = try await createStoredFileRelationshipsToTranslation(
            translationId: translationId,
            fileCacheLocations: fileCacheLocations
        )
        
        return fileCacheLocations
    }
    
    private func createStoredFileRelationshipsToTranslation(
        translationId: String,
        fileCacheLocations: [FileCacheLocation]
    ) async throws -> StoreResourcesFilesResult {
        
        let swiftDataRead = SwiftDataRead()
        
        var updateSha256Files: [SwiftSHA256File] = Array()
        
        for location in fileCacheLocations {
            
            let translation: SwiftTranslation? = try swiftDataRead.object(context: modelContext, id: translationId)

            guard let translation = translation else {
                throw NSError.errorWithDescription(
                    description: "Failed to create file relationships because a translation object does not exist in the database."
                )
            }
            
            guard let filenameWithPathExtension = location.filenameWithPathExtension else {
                continue
            }
            
            let existing: SwiftSHA256File? = try swiftDataRead.object(context: modelContext, id: filenameWithPathExtension)

            if let existing = existing {

                guard !existing.translations.contains(translation) else {
                    continue
                }

                existing.translations.append(translation)
            }
            else {

                let sha256File = SwiftSHA256File()
                sha256File.id = filenameWithPathExtension
                sha256File.sha256WithPathExtension = filenameWithPathExtension
                sha256File.translations.append(translation)

                updateSha256Files.append(sha256File)
            }
        }

        modelContext.insertObjects(objects: updateSha256Files)
        
        try modelContext.saveIfHasChanges()
        
        let deleteResourcesFilesResult = try await deleteUnusedResourceFiles()
        
        let storeResourcesFilesResult = StoreResourcesFilesResult(
            storedFiles: fileCacheLocations,
            deleteResourcesFilesResult: deleteResourcesFilesResult
        )
        
        return storeResourcesFilesResult
    }
    
    // MARK: - Delete Unused Files
    
    private func deleteUnusedResourceFiles() async throws -> DeleteResourcesFilesResult {
        
        let swiftDataRead = SwiftDataRead()
        
        let filter = #Predicate<SwiftSHA256File> { object in
            object.attachments.count == 0 && object.translations.count == 0
        }
                
        let sha256FilesToDelete: [SwiftSHA256File] = try swiftDataRead.objects(
            context: modelContext,
            query: SwiftDatabaseQuery.filter(filter: filter)
        )
                
        var filesToRemove: [FileCacheLocation] = Array()
        
        for file in sha256FilesToDelete {
            
            let location: FileCacheLocation = FileCacheLocation(relativeUrlString: file.sha256WithPathExtension)
            
            filesToRemove.append(location)
            
            try await resourcesFileCache.cache.removeFile(location: location)
        }
        
        modelContext.deleteObjects(objects: sha256FilesToDelete)
        
        try modelContext.saveIfHasChanges()
        
        return DeleteResourcesFilesResult(filesRemoved: filesToRemove)
    }
}
