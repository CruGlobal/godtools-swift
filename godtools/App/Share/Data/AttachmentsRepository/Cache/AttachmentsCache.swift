//
//  AttachmentsCache.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class AttachmentsCache: Sendable {
    
    private let resourcesFileCache: ResourcesFileCache
    private let resourcesSHA256FileCache: ResourcesSHA256FileCacheInterface
    private let bundle: AttachmentsBundleCache
    
    let persistence: any Persistence<AttachmentDataModel, AttachmentCodable>
    
    init(
        persistence: any Persistence<AttachmentDataModel, AttachmentCodable>,
        resourcesFileCache: ResourcesFileCache,
        resourcesSHA256FileCache: ResourcesSHA256FileCacheInterface,
        bundle: AttachmentsBundleCache
    ) {
        
        self.persistence = persistence
        self.resourcesFileCache = resourcesFileCache
        self.resourcesSHA256FileCache = resourcesSHA256FileCache
        self.bundle = bundle
    }
    
    @available(iOS 17.4, *)
    private var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<AttachmentDataModel, AttachmentCodable, SwiftAttachment>? {
        return persistence as? SwiftRepositorySyncPersistence<AttachmentDataModel, AttachmentCodable, SwiftAttachment>
    }
    
    private func getRealmPersistence() -> RealmRepositorySyncPersistence<AttachmentDataModel, AttachmentCodable, RealmAttachment>? {
        return persistence as? RealmRepositorySyncPersistence<AttachmentDataModel, AttachmentCodable, RealmAttachment>
    }
}

extension AttachmentsCache {
    
    func getAttachment(id: String) async throws -> AttachmentDataModel? {
                    
        guard let cachedAttachment = try persistence.getDataModel(id: id) else {
            return nil
        }
                
        let fileCacheLocation: FileCacheLocation = FileCacheLocation(
            relativeUrlString: cachedAttachment.sha256
        )
        
        let imageData: Data?
        
        if let bundleImageData = bundle.getBundledAttachment(resource: cachedAttachment.sha256)  {
            
            imageData = bundleImageData
        }
        else {
            
            imageData = try await resourcesFileCache.cache.getData(location: fileCacheLocation)
        }
        
        let storedAttachment: StoredAttachmentDataModel?
        
        if let imageData = imageData {
            
            storedAttachment = try await StoredAttachmentDataModel(
                data: imageData,
                fileCacheLocation: fileCacheLocation,
                resourcesFileCache: resourcesFileCache
            )
        }
        else {
            
            storedAttachment = nil
        }
        
        return cachedAttachment.copy(storedAttachment: storedAttachment)
    }
    
    func storeAttachmentData(attachment: AttachmentDataModel, data: Data) async throws -> StoredAttachmentDataModel {
        
        let location: FileCacheLocation = try await resourcesSHA256FileCache.storeAttachmentFile(
            attachmentId: attachment.id,
            fileName: attachment.sha256,
            fileData: data
        )
        
        return try await StoredAttachmentDataModel(
            data: data,
            fileCacheLocation: location,
            resourcesFileCache: resourcesFileCache
        )
    }
}
