//
//  AttachmentsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import RepositorySync
import Combine

class AttachmentsRepository: RepositorySync<AttachmentDataModel, MobileContentAttachmentsApi> {
        
    let cache: AttachmentsCache
    
    init(externalDataFetch: MobileContentAttachmentsApi, persistence: any Persistence<AttachmentDataModel, AttachmentCodable>, cache: AttachmentsCache) {
        
        self.cache = cache
        
        super.init(
            externalDataFetch: externalDataFetch,
            persistence: persistence
        )
    }
}

extension AttachmentsRepository {
    
    func getAttachmentFromCacheElseRemotePublisher(id: String, requestPriority: RequestPriority) -> AnyPublisher<AttachmentDataModel?, Error> {
        
        return cache.getAttachmentPublisher(id: id)
            .flatMap { (cachedAttachment: AttachmentDataModel?) -> AnyPublisher<AttachmentDataModel?, Error> in
                
                guard let cachedAttachment = cachedAttachment else {
                    return Just(nil)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                return self.getAttachmentWithDataFromCacheElseRemotePublisher(
                    attachment: cachedAttachment,
                    requestPriority: requestPriority
                )
                .eraseToAnyPublisher()
                
            }
            .eraseToAnyPublisher()
    }
    
    func downloadAndCacheAttachmentDataIfNeededPublisher(attachment: AttachmentDataModel, requestPriority: RequestPriority) -> AnyPublisher<AttachmentDataModel?, Error> {
        
        return getAttachmentWithDataFromCacheElseRemotePublisher(
            attachment: attachment,
            requestPriority: requestPriority
        )
        .eraseToAnyPublisher()
    }
    
    private func getAttachmentWithDataFromCacheElseRemotePublisher(attachment: AttachmentDataModel, requestPriority: RequestPriority) -> AnyPublisher<AttachmentDataModel?, Error> {
        
        return cache
            .getAttachmentPublisher(
                id: attachment.id
            )
            .flatMap({ (cachedAttachment: AttachmentDataModel?) -> AnyPublisher<AttachmentDataModel?, Error> in
                
                if let cachedAttachment = cachedAttachment, cachedAttachment.storedAttachment?.data != nil {
                    
                    return Just(cachedAttachment)
                        .setFailureType(to: Error.self)
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
    
    private func downloadAndCacheAttachmentPublisher(attachment: AttachmentDataModel, requestPriority: RequestPriority) -> AnyPublisher<AttachmentDataModel?, Error> {
        
        return getAndStoreAttachmentFilePublisher(
            attachment: attachment,
            requestPriority: requestPriority
        )
        .map { (storedAttachment: StoredAttachmentDataModel) in
            
            return AttachmentDataModel(interface: attachment, storedAttachment: storedAttachment)
        }
        .eraseToAnyPublisher()
    }
    
    private func getAndStoreAttachmentFilePublisher(attachment: AttachmentDataModel, requestPriority: RequestPriority) -> AnyPublisher<StoredAttachmentDataModel, Error> {
        
        guard let remoteUrl = URL(string: attachment.file) else {
            
            let error: Error = NSError.errorWithDescription(description: "Failed to create attachment file url.")
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return externalDataFetch.getAttachmentFilePublisher(url: remoteUrl, requestPriority: requestPriority)
            .flatMap({ (response: RequestDataResponse) -> AnyPublisher<StoredAttachmentDataModel, Error> in
                
                return self.cache.storeAttachmentDataPublisher(
                    attachment: attachment,
                    data: response.data
                )
            })
            .eraseToAnyPublisher()
    }
}
