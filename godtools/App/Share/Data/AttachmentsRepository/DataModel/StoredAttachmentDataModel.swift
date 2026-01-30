//
//  StoredAttachmentDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/17/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class StoredAttachmentDataModel {
    
    let data: Data
    let diskFileUrl: URL?
    let fileCacheLocation: FileCacheLocation
    
    init(data: Data, fileCacheLocation: FileCacheLocation, resourcesFileCache: ResourcesSHA256FileCache) throws {
        
        self.data = data
        self.diskFileUrl = try resourcesFileCache.getFile(location: fileCacheLocation)
        self.fileCacheLocation = fileCacheLocation
    }
}
