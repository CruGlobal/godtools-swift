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

final class AttachmentsRepository {
        
    private let api: AttachmentsApiInterface
    private let cache: AttachmentsCache
    
    init(api: AttachmentsApiInterface, cache: AttachmentsCache) {
        
        self.api = api
        self.cache = cache
    }
    
    var persistence: any Persistence<AttachmentDataModel, AttachmentCodable> {
        return cache.persistence
    }
    
    func getAttachment(id: String) -> AttachmentDataModel? {
        
        do {
            return try cache.getAttachment(id: id)
        }
        catch _ {
            return nil
        }
    }
}

extension AttachmentsRepository {
    
    func getAttachmentFromCacheElseRemotePublisher(id: String, requestPriority: RequestPriority) -> AnyPublisher<AttachmentDataModel?, Error> {
        
        let cachedAttachment: AttachmentDataModel? = getAttachment(id: id)
        
        guard let cachedAttachment = cachedAttachment else {
            return Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return AnyPublisher() {
            try await self.getAttachmentWithDataFromCacheElseRemote(attachment: cachedAttachment, requestPriority: requestPriority)
        }
        .eraseToAnyPublisher()
    }
    
    func downloadAndCacheAttachmentDataIfNeededPublisher(attachment: AttachmentDataModel, requestPriority: RequestPriority) -> AnyPublisher<AttachmentDataModel?, Error> {
        
        return AnyPublisher() {
            try await self.getAttachmentWithDataFromCacheElseRemote(attachment: attachment, requestPriority: requestPriority)
        }
        .eraseToAnyPublisher()
    }
    
    private func getAttachmentWithDataFromCacheElseRemote(attachment: AttachmentDataModel, requestPriority: RequestPriority) async throws -> AttachmentDataModel {
        
        let cachedAttachment: AttachmentDataModel? = try cache.getAttachment(id: attachment.id)
        
        if let cachedAttachment = cachedAttachment, cachedAttachment.storedAttachment?.data != nil {
            return cachedAttachment
        }
        
        return try await downloadAndCacheAttachment(
            attachment: attachment,
            requestPriority: requestPriority
        )
    }
    
    private func downloadAndCacheAttachment(attachment: AttachmentDataModel, requestPriority: RequestPriority) async throws -> AttachmentDataModel {
        
        guard let remoteUrl = URL(string: attachment.file) else {
            throw NSError.errorWithDescription(description: "Failed to create attachment file url.")
        }
        
        let response: RequestDataResponse = try await api.getAttachmentFile(
            url: remoteUrl,
            requestPriority: requestPriority
        )
        
        let storedAttachment: StoredAttachmentDataModel = try cache.storeAttachmentData(
            attachment: attachment,
            data: response.data
        )
        
        return attachment.copy(storedAttachment: storedAttachment)
    }
}
