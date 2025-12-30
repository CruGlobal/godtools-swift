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
import RepositorySync

class AttachmentsRepository: RepositorySync<AttachmentDataModel, MobileContentAttachmentsApi> {
    
    private let api: MobileContentAttachmentsApi
    
    let cache: AttachmentsCache
    
    init(api: MobileContentAttachmentsApi, cache: AttachmentsCache) {
        
        self.api = api
        self.cache = cache
        
        super.init(
            externalDataFetch: api,
            persistence: cache.getPersistence()
        )
    }
}

extension AttachmentsRepository {
    
    func getAttachmentFromCacheElseRemotePublisher(id: String, requestPriority: RequestPriority) -> AnyPublisher<AttachmentDataModel?, Never> {
        
        guard let cachedAttachment = cache.getAttachment(id: id) else {
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
        
        return cache.getAttachmentPublisher(id: attachment.id)
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
                
                return self.cache.storeAttachmentDataPublisher(
                    attachment: attachment,
                    data: response.data
                )
            })
            .catch { _ in
                return Just(nil)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
