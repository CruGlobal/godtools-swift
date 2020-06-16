//
//  AttachmentsFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 6/16/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class AttachmentsFileCache {
    
    private let realmCache: ResourcesRealmCache
    private let sha256FileCache: SHA256FilesCache
    
    required init(realmCache: ResourcesRealmCache, sha256FileCache: SHA256FilesCache) {
        
        self.realmCache = realmCache
        self.sha256FileCache = sha256FileCache
    }
    
    func getAttachmentBanner(attachmentId: String) {
        
    }
}
