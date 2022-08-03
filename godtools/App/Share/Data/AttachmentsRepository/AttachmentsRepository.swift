//
//  AttachmentsRepository.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

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
    
    func getAttachmentImage(id: String) -> AnyPublisher<Image?, URLResponseError> {
        
        return downloadAndCacheAttachmentFile(id: id)
            .flatMap({ location -> AnyPublisher<Image?, URLResponseError> in
                
                return self.resourcesFileCache.getImage(location: location).publisher
                    .mapError({ error in
                        return .otherError(error: error)
                    })
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func downloadAndCacheAttachmentFile(id: String) -> AnyPublisher<FileCacheLocation, URLResponseError> {
        
        guard let attachment = getAttachment(id: id) else {
            let error: Error = NSError.errorWithDescription(description: "Failed to download attachment file. Attachment does not exist in the realm database.")
            return Fail(error: .otherError(error: error))
                .eraseToAnyPublisher()
        }
        
        return downloadAndCacheAttachmentFile(attachment: attachment)
    }
    
    func downloadAndCacheAttachmentFile(attachment: AttachmentModel) -> AnyPublisher<FileCacheLocation, URLResponseError> {
        
        guard let url = URL(string: attachment.file) else {
            let error: Error = NSError.errorWithDescription(description: "Failed to download attachment file. Invalid URL if file attribute.")
            return Fail(error: .otherError(error: error))
                .eraseToAnyPublisher()
        }
        
        return api.getAttachmentFile(url: url)
            .flatMap({ responseObject -> AnyPublisher<FileCacheLocation, URLResponseError> in
                
                return self.resourcesFileCache.storeAttachmentFile(attachmentId: attachment.id, fileName: attachment.sha256, fileData: responseObject.data)
                    .mapError({ error in
                        return .otherError(error: error)
                    })
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
