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
    
    init(resourceId: String, languageCode: String, filename: String) {
        
        self.resourceId = resourceId
        self.languageCode = languageCode
        self.directory = resourceId + "/" + languageCode
        self.filename = filename
        self.fileExtension = "webarchive"
    }
}
