//
//  AttachmentsFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class AttachmentsFileCache {
    
    typealias AttachmentId = String
    
    private let realmDatabase: RealmDatabase
    private let sha256FileCache: ResourcesSHA256FileCache
    
    private var bannerImageMemoryCache: [AttachmentId: UIImage] = Dictionary() // TODO: Would like to replace this with a purging cache. ~Levi
    
    required init(realmDatabase: RealmDatabase, sha256FileCache: ResourcesSHA256FileCache) {
        
        self.realmDatabase = realmDatabase
        self.sha256FileCache = sha256FileCache
    }
    
    func getAttachmentBanner(attachmentId: String, complete: @escaping ((_ image: UIImage?) -> Void)) {
        
        if let image = bannerImageMemoryCache[attachmentId] {
            complete(image)
        }
        
        let sha256FileCacheRef: ResourcesSHA256FileCache = sha256FileCache
        
        realmDatabase.background { (realm: Realm) in
            
            var image: UIImage?
            
            let attachment: RealmAttachment? = realm.object(ofType: RealmAttachment.self, forPrimaryKey: attachmentId)
                
            if let attachment = attachment {
                
                let sha256FileLocation: SHA256FileLocation = attachment.sha256FileLocation
                                
                switch sha256FileCacheRef.getImage(location: sha256FileLocation) {
                case .success(let cachedImage):
                    image = cachedImage
                case .failure( _):
                    break
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                
                if let image = image {
                    self?.bannerImageMemoryCache[attachmentId] = image
                }
                
                complete(image)
            }
        }
    }
    
    func attachmentExists(location: SHA256FileLocation) -> Bool {
        
        switch sha256FileCache.fileExists(location: location) {
        case .success(let fileExists):
            return fileExists
        case .failure(let error):
            assertionFailure(error.localizedDescription)
            return false
        }
    }
    
    func cacheAttachmentFile(attachmentFile: AttachmentFile, fileData: Data, complete: @escaping ((_ error: Error?) -> Void)) {
        
        let location: SHA256FileLocation = attachmentFile.location
        
        let cacheError: Error? = sha256FileCache.cacheSHA256File(location: location, fileData: fileData)
        
        if let cacheError = cacheError {
            complete(cacheError)
        }
        else {
            addAttachmentReferencesIfNeeded(attachmentFile: attachmentFile, complete: complete)
        }
    }
    
    func addAttachmentReferencesIfNeeded(attachmentFile: AttachmentFile, complete: @escaping ((_ error: Error?) -> Void)) {
            
        guard !attachmentFile.relatedAttachmentIds.isEmpty else {
            complete(nil)
            return
        }
        
        let location: SHA256FileLocation = attachmentFile.location
        
        realmDatabase.background { (realm: Realm) in
            
            var attachmentReferences: [RealmAttachment] = Array()
            var cacheError: Error?
            
            for attachmentId in attachmentFile.relatedAttachmentIds {
                if let realmAttachment = realm.object(ofType: RealmAttachment.self, forPrimaryKey: attachmentId) {
                    attachmentReferences.append(realmAttachment)
                }
            }
            
            if let existingRealmSHA256File = realm.object(ofType: RealmSHA256File.self, forPrimaryKey: location.sha256WithPathExtension) {
                
                do {
                    try realm.write {
                        for attachment in attachmentReferences {
                            if !existingRealmSHA256File.attachments.contains(attachment) {
                                existingRealmSHA256File.attachments.append(attachment)
                            }
                        }
                    }
                }
                catch let error {
                    cacheError = error
                }
            }
            else {
                
                let newRealmSHA256File: RealmSHA256File = RealmSHA256File()
                newRealmSHA256File.sha256WithPathExtension = location.sha256WithPathExtension
                newRealmSHA256File.attachments.append(objectsIn: attachmentReferences)
                do {
                    try realm.write {
                        realm.add(newRealmSHA256File, update: .all)
                    }
                }
                catch let error {
                    cacheError = error
                }
            }
            
            complete(cacheError)
            
        }// end realmDatabase.background
    }
}
