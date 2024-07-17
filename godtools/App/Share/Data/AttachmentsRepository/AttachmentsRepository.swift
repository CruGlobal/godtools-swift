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
    
    func getAttachmentDataFromCache(id: String) -> Data? {
        
        guard let attachmentModel = cache.getAttachmentModel(id: id) else {
            return nil
        }
        
        guard let attachment = getAttachmentFromCache(attachment: attachmentModel) else {
            return nil
        }
        
        return attachment.data
    }
    
    func getAttachmentImageFromCache(id: String) -> Image? {
        
        guard let data = getAttachmentDataFromCache(id: id), let uiImage = UIImage(data: data) else {
            return nil
        }
        
        return Image(uiImage: uiImage)
    }
    
    func getAttachmentImagePublisher(id: String) -> AnyPublisher<Image?, Never> {
        
        return getAttachmentModelPublisher(id: id)
            .flatMap({ attachment -> AnyPublisher<AttachmentDataModel, Error> in
              
                return self.getAttachmentFromCacheElseRemote(attachment: attachment)
                    .eraseToAnyPublisher()
            })
            .flatMap({ attachmentDataModel -> AnyPublisher<Image?, Error> in
                
                guard let uiImage = UIImage(data: attachmentDataModel.data) else {
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
    
    func getAttachmentDataPublisher(id: String) -> AnyPublisher<Data?, Never> {

        return getAttachmentModelPublisher(id: id)
            .flatMap({ attachment -> AnyPublisher<AttachmentDataModel, Error> in
    
                return self.getAttachmentFromCacheElseRemote(attachment: attachment)
                    .eraseToAnyPublisher()
            })
            .flatMap({ attachmentDataModel -> AnyPublisher<Data?, Error> in
                
                return Just(attachmentDataModel.data)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .catch { _ in
                return Just(nil)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getAttachmentUrlPublisher(id: String) -> AnyPublisher<URL?, Never> {
         
        return getAttachmentModelPublisher(id: id)
            .flatMap({ attachment -> AnyPublisher<AttachmentDataModel, Error> in
    
                return self.getAttachmentFromCacheElseRemote(attachment: attachment)
                    .eraseToAnyPublisher()
            })
            .flatMap({ attachmentDataModel -> AnyPublisher<URL?, Error> in
                
                return self.resourcesFileCache.getFile(location: attachmentDataModel.fileCacheLocation).publisher
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
    
    func getAttachmentModel(id: String) -> AttachmentModel? {
        return cache.getAttachmentModel(id: id)
    }
    
    private func getAttachmentModelPublisher(id: String) -> AnyPublisher<AttachmentModel, Error> {
        
        guard let attachmentModel = getAttachmentModel(id: id) else {
            
            let error: Error = NSError.errorWithDescription(description: "Failed to download attachment file. Attachment does not exist in realm database.")
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return Just(attachmentModel).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func getAttachmentFromCacheElseRemote(attachment: AttachmentModel) -> AnyPublisher<AttachmentDataModel, Error> {
        
        return getAttachmentFromCachePublisher(attachment: attachment)
            .catch { (error: Error) in
                return self.downloadAndCacheAttachment(attachment: attachment)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func getAttachmentFromCache(attachment: AttachmentModel) -> AttachmentDataModel? {
        
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
            
            return nil
        }
        
        return AttachmentDataModel(attachmentModel: attachment, data: imageData, fileCacheLocation: location)
    }
    
    private func getAttachmentFromCachePublisher(attachment: AttachmentModel) -> AnyPublisher<AttachmentDataModel, Error> {
                
        guard let attachmentData = getAttachmentFromCache(attachment: attachment) else {
            
            let error: Error = NSError.errorWithDescription(description: "Failed to get imageData from attachments file cache.")
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }

        return Just(attachmentData)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func downloadAndCacheAttachment(attachment: AttachmentModel) -> AnyPublisher<AttachmentDataModel, Error> {
        
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
            .flatMap({ (data: Data, fileCacheLocation: FileCacheLocation) -> AnyPublisher<AttachmentDataModel, Error> in
            
                let attachmentDataModel = AttachmentDataModel(
                    attachmentModel: attachment,
                    data: data,
                    fileCacheLocation: fileCacheLocation
                )
                
                return Just(attachmentDataModel)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func downloadAndCacheAttachmentIfNeeded(attachment: AttachmentModel) -> AnyPublisher<AttachmentDataModel, Error> {
        
        return getAttachmentFromCachePublisher(attachment: attachment)
            .catch { (error: Error) in
                return self.downloadAndCacheAttachment(attachment: attachment)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
