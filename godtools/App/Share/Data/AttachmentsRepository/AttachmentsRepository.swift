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
import UIKit
import RequestOperation

class AttachmentsRepository {
    
    private let api: MobileContentAttachmentsApi
    private let cache: RealmAttachmentsCache
    private let resourcesFileCache: ResourcesSHA256FileCache
    private let bundle: AttachmentsBundleCache
    
    init(api: MobileContentAttachmentsApi, cache: RealmAttachmentsCache, resourcesFileCache: ResourcesSHA256FileCache, bundle: AttachmentsBundleCache) {
        
        self.api = api
        self.cache = cache
        self.resourcesFileCache = resourcesFileCache
        self.bundle = bundle
    }
    
    func getAttachmentImage(id: String) -> AnyPublisher<Image?, Never> {
        
        return getAttachment(id: id)
            .flatMap({ attachment -> AnyPublisher<AttachmentFileDataModel, Error> in
              
                return self.getAttachmentFromCacheElseRemote(attachment: attachment)
                    .eraseToAnyPublisher()
            })
            .flatMap({ attachmentFileDataModel -> AnyPublisher<Image?, Error> in
                
                guard let uiImage = UIImage(data: attachmentFileDataModel.data) else {
                    return Just(nil)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                let image: Image = Image(uiImage: uiImage)
                
                return Just(image)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .catch { _ in
                return Just(nil)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getAttachmentData(id: String) -> AnyPublisher<Data?, Never> {

        return getAttachment(id: id)
            .flatMap({ attachment -> AnyPublisher<AttachmentFileDataModel, Error> in
    
                return self.getAttachmentFromCacheElseRemote(attachment: attachment)
                    .eraseToAnyPublisher()
            })
            .flatMap({ attachmentFileDataModel -> AnyPublisher<Data?, Error> in
                
                return Just(attachmentFileDataModel.data)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .catch { _ in
                return Just(nil)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getAttachmentUrl(id: String) -> AnyPublisher<URL?, Never> {
         
        return getAttachment(id: id)
            .flatMap({ attachment -> AnyPublisher<AttachmentFileDataModel, Error> in
    
                return self.getAttachmentFromCacheElseRemote(attachment: attachment)
                    .eraseToAnyPublisher()
            })
            .flatMap({ attachmentFileDataModel -> AnyPublisher<URL?, Error> in
                
                return self.resourcesFileCache.getFile(location: attachmentFileDataModel.fileCacheLocation).publisher
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
    
    private func getAttachment(id: String) -> AnyPublisher<AttachmentModel, Error> {
        
        guard let attachment = cache.getAttachment(id: id) else {
            
            let error: Error = NSError.errorWithDescription(description: "Failed to download attachment file. Attachment does not exist in realm database.")
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return Just(attachment).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func getAttachmentFromCacheElseRemote(attachment: AttachmentModel) -> AnyPublisher<AttachmentFileDataModel, Error> {
        
        return getAttachmentFromCache(attachment: attachment)
            .catch { (error: Error) in
                return self.downloadAndCacheAttachment(attachment: attachment)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func getAttachmentFromCache(attachment: AttachmentModel) -> AnyPublisher<AttachmentFileDataModel, Error> {
        
        let location = FileCacheLocation(relativeUrlString: attachment.sha256)
        
        let imageData: Data?
        
        if let bundleImageData = bundle.getAttachmentData(attachment: attachment)  {
            
            imageData = bundleImageData
        }
        else {
            
            switch resourcesFileCache.getData(location: location) {
            case .success(let data):
                imageData = data
            case .failure( _):
                imageData = nil
            }
        }
        
        guard let imageData = imageData else {
            
            let error: Error = NSError.errorWithDescription(description: "Failed to get imageData from attachments file cache.")
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }

        return Just(AttachmentFileDataModel(attachment: attachment, data: imageData, fileCacheLocation: location))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func downloadAndCacheAttachment(attachment: AttachmentModel) -> AnyPublisher<AttachmentFileDataModel, Error> {
        
        guard let url = URL(string: attachment.file) else {
            let error: Error = NSError.errorWithDescription(description: "Failed to download attachment file. Invalid URL if file attribute.")
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return api.getAttachmentFile(url: url)
            .flatMap({ (requestResponse: UrlRequestResponse) -> AnyPublisher<(Data, FileCacheLocation), Error> in
                
                let justData = Just(requestResponse.data)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
                
                let storeAttachment = self.resourcesFileCache.storeAttachmentFile(
                    attachmentId: attachment.id,
                    fileName: attachment.sha256,
                    fileData: requestResponse.data
                )
                
                return justData.zip(storeAttachment)
                    .eraseToAnyPublisher()
            })
            .flatMap({ (data: Data, fileCacheLocation: FileCacheLocation) -> AnyPublisher<AttachmentFileDataModel, Error> in
            
                let attachmentFileDataModel = AttachmentFileDataModel(
                    attachment: attachment,
                    data: data,
                    fileCacheLocation: fileCacheLocation
                )
                
                return Just(attachmentFileDataModel)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
