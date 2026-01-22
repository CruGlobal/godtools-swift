//
//  AttachmentsCache.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import Combine

class AttachmentsCache {
    
    private let persistence: any Persistence<AttachmentDataModel, AttachmentCodable>
    private let resourcesFileCache: ResourcesSHA256FileCache
    private let bundle: AttachmentsBundleCache
    
    init(persistence: any Persistence<AttachmentDataModel, AttachmentCodable>, resourcesFileCache: ResourcesSHA256FileCache, bundle: AttachmentsBundleCache) {
        
        self.persistence = persistence
        self.resourcesFileCache = resourcesFileCache
        self.bundle = bundle
    }
    
    @available(iOS 17.4, *)
    var swiftDatabase: SwiftDatabase? {
        return getSwiftPersistence()?.database
    }
    
    @available(iOS 17.4, *)
    func getSwiftPersistence() -> SwiftRepositorySyncPersistence<AttachmentDataModel, AttachmentCodable, SwiftAttachment>? {
        return persistence as? SwiftRepositorySyncPersistence<AttachmentDataModel, AttachmentCodable, SwiftAttachment>
    }
    
    var realmDatabase: RealmDatabase? {
        return getRealmPersistence()?.database
    }
    
    func getRealmPersistence() -> RealmRepositorySyncPersistence<AttachmentDataModel, AttachmentCodable, RealmAttachment>? {
        return persistence as? RealmRepositorySyncPersistence<AttachmentDataModel, AttachmentCodable, RealmAttachment>
    }
}

extension AttachmentsCache {
    
    func getAttachment(id: String) throws -> AttachmentDataModel? {
            
        let cachedAttachment: AttachmentDataModelInterface?
        
        if #available(iOS 17.4, *), let swiftDatabase = swiftDatabase {
            let swiftAttachment: SwiftAttachment? = swiftDatabase.read.objectNonThrowing(context: swiftDatabase.openContext(), id: id)
            cachedAttachment = swiftAttachment
        }
        else if let realmDatabase = realmDatabase, let realm = realmDatabase.openRealmNonThrowing() {
            let realmAttachment: RealmAttachment? = realmDatabase.read.object(realm: realm, id: id)
            cachedAttachment = realmAttachment
        }
        else {
            cachedAttachment = nil
        }
        
        guard let cachedAttachment = cachedAttachment else {
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
            
            imageData = try resourcesFileCache.getData(location: fileCacheLocation)
        }
        
        let storedAttachment: StoredAttachmentDataModel?
        
        if let imageData = imageData {
            
            storedAttachment = try StoredAttachmentDataModel(
                data: imageData,
                fileCacheLocation: fileCacheLocation,
                resourcesFileCache: resourcesFileCache
            )
        }
        else {
            
            storedAttachment = nil
        }

        return AttachmentDataModel(
            interface: cachedAttachment,
            storedAttachment: storedAttachment
        )
    }
    
    func getAttachmentPublisher(id: String) -> AnyPublisher<AttachmentDataModel?, Error> {
        
        let attachment: AttachmentDataModel?
        
        do {
            attachment = try getAttachment(id: id)
        }
        catch let error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return Just(attachment)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func storeAttachmentDataPublisher(attachment: AttachmentDataModel, data: Data) -> AnyPublisher<StoredAttachmentDataModel, Error> {
        
        let resourcesFileCache: ResourcesSHA256FileCache = self.resourcesFileCache
        
        return resourcesFileCache.storeAttachmentFilePublisher(
            attachmentId: attachment.id,
            fileName: attachment.sha256,
            fileData: data
        )
        .tryMap { (location: FileCacheLocation) in
            
            return try StoredAttachmentDataModel(
                data: data,
                fileCacheLocation: location,
                resourcesFileCache: resourcesFileCache
            )
        }
        .eraseToAnyPublisher()
    }
}
