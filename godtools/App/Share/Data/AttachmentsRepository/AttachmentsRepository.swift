//
//  AttachmentsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

class AttachmentsRepository: RepositorySync<AttachmentDataModel, MobileContentAttachmentsApi, RealmAttachment> {
    
    private let api: MobileContentAttachmentsApi
    private let resourcesFileCache: ResourcesSHA256FileCache
    private let bundle: AttachmentsBundleCache
    
    init(api: MobileContentAttachmentsApi, realmDatabase: RealmDatabase, resourcesFileCache: ResourcesSHA256FileCache, bundle: AttachmentsBundleCache) {
        
        self.api = api
        self.resourcesFileCache = resourcesFileCache
        self.bundle = bundle
        
        super.init(
            externalDataFetch: api,
            realmDatabase: realmDatabase,
            dataModelMapping: AttachmentsDataModelMapping()
        )
    }
}

// MARK: - Cache

extension AttachmentsRepository {
    
    func getCachedAttachment(id: String) -> AttachmentDataModel? {
        
        guard let cachedAttachment = getCachedObject(id: id) else {
            return nil
        }
        
        let fileCacheLocation: FileCacheLocation = FileCacheLocation(
            relativeUrlString: cachedAttachment.sha256
        )
        
        let imageData: Data?
        
        if let bundleImageData = bundle.getAttachmentData(resource: cachedAttachment.sha256)  {
            
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
            storedAttachment = StoredAttachmentDataModel(data: imageData, fileCacheLocation: fileCacheLocation, resourcesFileCache: resourcesFileCache)
        }
        else {
            storedAttachment = nil
        }

        return AttachmentDataModel(
            interface: cachedAttachment,
            storedAttachment: storedAttachment
        )
    }
    
    func getCachedAttachmentPublisher(id: String) -> AnyPublisher<AttachmentDataModel?, Never> {
        return Just(getCachedAttachment(id: id))
            .eraseToAnyPublisher()
    }
}

extension AttachmentsRepository {
    
    func getAttachmentFromCacheElseRemotePublisher(id: String, requestPriority: RequestPriority) -> AnyPublisher<AttachmentDataModel?, Never> {
        
        guard let cachedAttachment = getCachedAttachment(id: id) else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        
        return getAttachmentWithDataFromCacheElseRemotePublisher(
            attachment: cachedAttachment,
            requestPriority: requestPriority
        )
        .eraseToAnyPublisher()
    }
    
    func downloadAndCacheAttachmentDataIfNeededPublisher(attachment: AttachmentDataModel, requestPriority: RequestPriority) -> AnyPublisher<AttachmentDataModel?, Never> {
        return getAttachmentWithDataFromCacheElseRemotePublisher(
            attachment: attachment,
            requestPriority: requestPriority
        )
        .eraseToAnyPublisher()
    }
    
    private func getAttachmentWithDataFromCacheElseRemotePublisher(attachment: AttachmentDataModel, requestPriority: RequestPriority) -> AnyPublisher<AttachmentDataModel?, Never> {
        
        return getCachedAttachmentPublisher(id: attachment.id)
            .flatMap({ (cachedAttachment: AttachmentDataModel?) -> AnyPublisher<AttachmentDataModel?, Never> in
                
                if let cachedAttachment = cachedAttachment, cachedAttachment.storedAttachment?.data != nil {
                    
                    return Just(cachedAttachment)
                        .eraseToAnyPublisher()
                }
                else {
                    
                    return self.downloadAndCacheAttachmentPublisher(
                        attachment: attachment,
                        requestPriority: requestPriority
                    )
                    .eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func downloadAndCacheAttachmentPublisher(attachment: AttachmentDataModel, requestPriority: RequestPriority) -> AnyPublisher<AttachmentDataModel?, Never> {
        
        return getAndStoreAttachmentFilePublisher(
            attachment: attachment,
            requestPriority: requestPriority
        )
        .map { (storedAttachment: StoredAttachmentDataModel?) in
            AttachmentDataModel(interface: attachment, storedAttachment: storedAttachment)
        }
        .eraseToAnyPublisher()
    }
    
    private func getAndStoreAttachmentFilePublisher(attachment: AttachmentDataModel, requestPriority: RequestPriority) -> AnyPublisher<StoredAttachmentDataModel?, Never> {
        
        guard let remoteUrl = URL(string: attachment.file) else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        
        return api.getAttachmentFile(url: remoteUrl, requestPriority: requestPriority)
            .flatMap({ (response: RequestDataResponse) -> AnyPublisher<StoredAttachmentDataModel?, Never> in
                
                return self.resourcesFileCache.storeAttachmentFilePublisher(
                    attachmentId: attachment.id,
                    fileName: attachment.sha256,
                    fileData: response.data
                )
                .map { (location: FileCacheLocation) in
                    StoredAttachmentDataModel(
                        data: response.data,
                        fileCacheLocation: location,
                        resourcesFileCache: self.resourcesFileCache
                    )
                }
                .catch { _ in
                    return Just(nil)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            })
            .catch { _ in
                return Just(nil)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
