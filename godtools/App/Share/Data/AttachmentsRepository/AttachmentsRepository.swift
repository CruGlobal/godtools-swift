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
    
    func getAttachmentImage(id: String) -> AnyPublisher<Image?, Never> {
        
        return getAttachmentFromCacheElseRemote(id: id)
            .flatMap({ fileCacheLocation -> AnyPublisher<Image?, URLResponseError> in
             
                return self.resourcesFileCache.getImage(location: fileCacheLocation).publisher
                    .mapError { error in
                        return URLResponseError.otherError(error: error)
                    }
                    .map { image in
                        return image
                    }
                    .eraseToAnyPublisher()
            })
            .catch({ error in
                
                return Just(nil)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func getAttachmentUrl(id: String) -> AnyPublisher<URL?, Never> {
        
        return getAttachmentFromCacheElseRemote(id: id)
            .flatMap({ fileCacheLocation -> AnyPublisher<URL?, URLResponseError> in
             
                return self.resourcesFileCache.getFile(location: fileCacheLocation).publisher
                    .mapError { error in
                        return URLResponseError.otherError(error: error)
                    }
                    .map { url in
                        return url
                    }
                    .eraseToAnyPublisher()
            })
            .catch({ error in
                
                return Just(nil)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}

extension AttachmentsRepository {
    
    private func getAttachment(id: String) -> AttachmentModel? {
        
        return cache.getAttachment(id: id)
    }
    
    private func getAttachmentFromCacheElseRemote(id: String) -> AnyPublisher<FileCacheLocation, URLResponseError> {
        
        guard let attachment = getAttachment(id: id) else {
            let error: Error = NSError.errorWithDescription(description: "Failed to download attachment file. Attachment does not exist in realm database.")
            return Fail(error: .otherError(error: error))
                .eraseToAnyPublisher()
        }
        
        return getAttachmentFromCacheElseRemote(attachment: attachment)
    }
    
    private func getAttachmentFromCacheElseRemote(attachment: AttachmentModel) -> AnyPublisher<FileCacheLocation, URLResponseError> {
        
        return getAttachmentFromCache(attachment: attachment).publisher
            .mapError({ error in
                return .otherError(error: error)
            })
            .flatMap({ fileCacheLocation -> AnyPublisher<FileCacheLocation, URLResponseError> in
                
                return Just(fileCacheLocation).setFailureType(to: URLResponseError.self)
                    .eraseToAnyPublisher()
            })
            .catch({ error in
                
                return self.downloadAndCacheAttachment(attachment: attachment)
            })
            .eraseToAnyPublisher()
    }
    
    private func getAttachmentFromCache(attachment: AttachmentModel) -> Result<FileCacheLocation, Error> {
        
        let location = FileCacheLocation(relativeUrlString: attachment.sha256)
        
        switch resourcesFileCache.getFileExists(location: location) {
            
        case .success(let fileExists):
            guard fileExists else {
                return .failure(NSError.errorWithDescription(description: "Attachment File does not exist in cache."))
            }
            
            return .success(location)
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func downloadAndCacheAttachment(attachment: AttachmentModel) -> AnyPublisher<FileCacheLocation, URLResponseError> {
        
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
