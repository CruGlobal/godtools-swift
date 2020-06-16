//
//  AttachmentsFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import RealmSwift

class AttachmentsFileCache {
    
    private let realmResources: RealmResourcesCache
    private let realmSHA256FileCache: RealmSHA256FileCache
    private let sha256FileCache: SHA256FilesCache
    
    required init(realmResources: RealmResourcesCache, realmSHA256FileCache: RealmSHA256FileCache, sha256FileCache: SHA256FilesCache) {
        
        self.realmResources = realmResources
        self.realmSHA256FileCache = realmSHA256FileCache
        self.sha256FileCache = sha256FileCache
    }
    
    func getAttachmentBanner(attachmentId: String) -> UIImage? {
        
        if let attachment = realmResources.getAttachment(id: attachmentId),
            let realmFile = realmSHA256FileCache.getSHA256File(sha256: attachment.sha256) {
            
            switch sha256FileCache.getImage(location: realmFile.location) {
            case .success(let image):
                return image
            case .failure( _):
                return nil
            }
        }
        
        return nil
    }
}
