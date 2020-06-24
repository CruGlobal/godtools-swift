//
//  ResourcesDownloaderResult.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourcesDownloaderResult {
    
    let latestAttachmentFiles: [AttachmentFile]
    
    required init(latestAttachmentFiles: [AttachmentFile]) {
        
        self.latestAttachmentFiles = latestAttachmentFiles
    }
}
