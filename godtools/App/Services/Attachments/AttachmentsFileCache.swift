//
//  AttachmentsFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import RealmSwift

class AttachmentsFileCache {
    
    typealias AttachmentId = String
    
    private let realmDatabase: RealmDatabase
    private let sha256FileCache: ResourcesSHA256FileCache
        
    required init(realmDatabase: RealmDatabase, sha256FileCache: ResourcesSHA256FileCache) {
        
        self.realmDatabase = realmDatabase
        self.sha256FileCache = sha256FileCache
    }
    
    func getAttachmentBanner(attachmentId: String) -> UIImage? {
        
        // TODO: Fix in GT-1448. ~Levi
        
        /*
        let realm: Realm = realmDatabase.mainThreadRealm
        let sha256FileCacheRef: ResourcesSHA256FileCache = sha256FileCache
                
        let attachment: RealmAttachment? = realm.object(ofType: RealmAttachment.self, forPrimaryKey: attachmentId)
            
        if let attachment = attachment {
            
            let sha256FileLocation: SHA256FileLocation = attachment.sha256FileLocation
                            
            switch sha256FileCacheRef.getImage(location: sha256FileLocation) {
            case .success(let cachedImage):
                return cachedImage
            case .failure( _):
                break
            }
        }*/
        
        return nil
    }
    
    func getAttachmentFileUrl(attachmentId: String) -> URL? {
              
        // TODO: Fix in GT-1448. ~Levi
        
        /*
        guard let attachment = realmDatabase.mainThreadRealm.object(ofType: RealmAttachment.self, forPrimaryKey: attachmentId) else {
            return nil
        }
        
        switch sha256FileCache.getFile(location: attachment.sha256FileLocation) {
        case .success(let url):
            return url
        case .failure( _):
            return nil
        }*/
        
        return nil
    }
    
    func attachmentExists(location: SHA256FileLocation) -> Bool {
        
        // TODO: Fix in GT-1448. ~Levi
        
        /*
        switch sha256FileCache.fileExists(location: location) {
        case .success(let fileExists):
            return fileExists
        case .failure(let error):
            assertionFailure(error.localizedDescription)
            return false
        }*/
        
        return false
    }
    
    func cacheAttachmentFile(attachmentFile: AttachmentFile, fileData: Data, complete: @escaping ((_ error: Error?) -> Void)) {
        
        // TODO: Fix in GT-1448. ~Levi
        
        /*
        let location: SHA256FileLocation = attachmentFile.location
        
        let cacheError: Error? = sha256FileCache.cacheSHA256File(location: location, fileData: fileData)
        
        if let cacheError = cacheError {
            complete(cacheError)
        }
        else {
            addAttachmentReferencesIfNeeded(attachmentFile: attachmentFile, complete: complete)
        }*/
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
