//
//  ResourcesCacheResult.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourcesCacheResult {
    
    let resourceIdsRemoved: [String]
    let languageIdsRemoved: [String]
    let translationIdsRemoved: [String]
    let attachmentIdsRemoved: [String]
    let latestAttachmentFiles: [AttachmentFile]
    
    required init(resourceIdsRemoved: [String], languageIdsRemoved: [String], translationIdsRemoved: [String], attachmentIdsRemoved: [String], latestAttachmentFiles: [AttachmentFile]) {
        
        self.resourceIdsRemoved = resourceIdsRemoved
        self.languageIdsRemoved = languageIdsRemoved
        self.translationIdsRemoved = translationIdsRemoved
        self.attachmentIdsRemoved = attachmentIdsRemoved
        self.latestAttachmentFiles = latestAttachmentFiles
    }
    
    var didRemoveCachedResources: Bool {
        return !resourceIdsRemoved.isEmpty || !languageIdsRemoved.isEmpty || !translationIdsRemoved.isEmpty || !attachmentIdsRemoved.isEmpty
    }
}
