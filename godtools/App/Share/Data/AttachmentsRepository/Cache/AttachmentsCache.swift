//
//  AttachmentsCache.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class AttachmentsCache: SwiftElseRealmPersistence<AttachmentDataModel, AttachmentCodable, RealmAttachment> {
    
    private let resourcesFileCache: ResourcesSHA256FileCache
    private let bundle: AttachmentsBundleCache
    
    init(resourcesFileCache: ResourcesSHA256FileCache, bundle: AttachmentsBundleCache, realmDatabase: RealmDatabase) {
        
        self.resourcesFileCache = resourcesFileCache
        self.bundle = bundle
        
        super.init(
            realmDatabase: realmDatabase,
            realmDataModelMapping: RealmAttachmentDataModelMapping(),
            swiftPersistenceIsEnabled: nil
        )
    }
    
    @available(iOS 17.4, *)
    override func getAnySwiftPersistence(swiftDatabase: SwiftDatabase) -> (any RepositorySyncPersistence<AttachmentDataModel, AttachmentCodable>)? {
        return getSwiftPersistence(swiftDatabase: swiftDatabase)
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence() -> SwiftRepositorySyncPersistence<AttachmentDataModel, AttachmentCodable, SwiftAttachment>? {
        
        guard let swiftDatabase = super.getSwiftDatabase() else {
            return nil
        }
        
        return getSwiftPersistence(swiftDatabase: swiftDatabase)
    }
    
    @available(iOS 17.4, *)
    private func getSwiftPersistence(swiftDatabase: SwiftDatabase) -> SwiftRepositorySyncPersistence<AttachmentDataModel, AttachmentCodable, SwiftAttachment>? {
        
        guard let swiftDatabase = super.getSwiftDatabase() else {
            return nil
        }
        
        return SwiftRepositorySyncPersistence(
            swiftDatabase: swiftDatabase,
            dataModelMapping: SwiftAttachmentDataModelMapping()
        )
    }
}

extension AttachmentsCache {
    
    func getAttachment(id: String) -> AttachmentDataModel? {
        
        guard let cachedAttachment = super.getPersistence().getObject(id: id) else {
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
            
            switch resourcesFileCache.getData(location: fileCacheLocation) {
            
            case .success(let data):
                imageData = data
            
            case .failure( _):
                imageData = nil
            }
        }
        
        let storedAttachment: StoredAttachmentDataModel?
        
        if let imageData = imageData {
            
            storedAttachment = StoredAttachmentDataModel(
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
    
    func getAttachmentPublisher(id: String) -> AnyPublisher<AttachmentDataModel?, Never> {
        
        return Just(getAttachment(id: id))
            .eraseToAnyPublisher()
    }
    
    func storeAttachmentDataPublisher(attachment: AttachmentDataModel, data: Data) -> AnyPublisher<StoredAttachmentDataModel?, Never> {
        
        let resourcesFileCache: ResourcesSHA256FileCache = self.resourcesFileCache
        
        return resourcesFileCache.storeAttachmentFilePublisher(
            attachmentId: attachment.id,
            fileName: attachment.sha256,
            fileData: data
        )
        .map { (location: FileCacheLocation) in
            
            StoredAttachmentDataModel(
                data: data,
                fileCacheLocation: location,
                resourcesFileCache: resourcesFileCache
            )
        }
        .catch { _ in
            
            return Just(nil)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
