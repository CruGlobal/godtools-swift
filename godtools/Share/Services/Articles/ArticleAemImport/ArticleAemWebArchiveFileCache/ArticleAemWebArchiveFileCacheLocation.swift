//
//  ArticleAemWebArchiveFileCacheLocation.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleAemWebArchiveFileCacheLocation: FileCacheLocationType {
    
    let resourceId: String
    let languageCode: String
    let directory: String
    let filename: String
    let fileExtension: String?
    
    init(godToolsResource: GodToolsResource, filename: String) {
        
        resourceId = godToolsResource.resourceId
        languageCode = godToolsResource.languageCode
        
        directory = resourceId + "/" + languageCode
        
        self.filename = filename
        self.fileExtension = "webarchive"
    }
}
