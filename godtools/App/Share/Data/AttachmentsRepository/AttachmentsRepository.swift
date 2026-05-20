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
    
    @MainActor func observeCollectionChangesPublisher() -> AnyPublisher<Void, Error> {
        return cache
            .persistence
            .observeCollectionChangesPublisher()
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
    
    func getAttachmentFromCacheElseRemote(id: String, requestPriority: RequestPriority) async throws -> AttachmentDataModel? {
        
        let cachedAttachment: AttachmentDataModel? = try cache.getAttachment(id: id)
        
        guard let cachedAttachment = cachedAttachment else {
            return nil
        }
        
        return try await getAttachmentFromCacheElseRemote(
            attachment: cachedAttachment,
            requestPriority: requestPriority
        )
    }
    
    func downloadAndCacheAttachmentDataIfNeeded(attachment: AttachmentDataModel, requestPriority: RequestPriority) async throws -> AttachmentDataModel {
            
        return try await getAttachmentFromCacheElseRemote(
            attachment: attachment,
            requestPriority: requestPriority
        )
    }
    
    private func getAttachmentFromCacheElseRemote(attachment: AttachmentDataModel, requestPriority: RequestPriority) async throws -> AttachmentDataModel {
        
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
        
        let storedAttachment: StoredAttachmentDataModel = try await cache.storeAttachmentData(
            attachment: attachment,
            data: response.data
        )
        
        return attachment.copy(storedAttachment: storedAttachment)
    }
}
