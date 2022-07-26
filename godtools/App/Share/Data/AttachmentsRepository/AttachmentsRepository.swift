//
//  AttachmentsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class AttachmentsRepository {
    
    private let api: MobileContentAttachmentsApi
    private let cache: RealmAttachmentsCache
    private let resourcesFileCache: ResourcesSHA256FileCache
    
    init(api: MobileContentAttachmentsApi, cache: RealmAttachmentsCache, resourcesFileCache: ResourcesSHA256FileCache) {
        
        self.api = api
        self.cache = cache
        self.resourcesFileCache = resourcesFileCache
    }
    
    func getAttachment(id: String) -> AttachmentModel? {
        
        return cache.getAttachment(id: id)
    }
    
    func storeAttachments(attachments: [AttachmentModel], deletesNonExisting: Bool) -> AnyPublisher<[AttachmentModel], Error> {
        
        return cache.storeAttachments(attachments: attachments, deletesNonExisting: true)
    }
}

extension AttachmentsRepository {
    
    private func downloadAndCacheAttachmentFile(attachmentId: String) -> AnyPublisher<Bool, Error> {

        guard let attachment = cache.getAttachment(id: attachmentId) else {
            return Fail(error: NSError.errorWithDescription(description: "Failed to download attachment file because an attachment does not exist in the database."))
                .eraseToAnyPublisher()
        }
        
        guard let url = URL(string: attachment.file) else {
            return Fail(error: NSError.errorWithDescription(description: "Failed to download attachment file. Invalid URL if file attribute."))
                .eraseToAnyPublisher()
        }
        
        return api.getAttachmentFile(url: url)
            .mapError { error in
                return error as Error
            }
            .flatMap({ urlResponseObject -> AnyPublisher<Bool, Error> in
                
                return Just(true).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
