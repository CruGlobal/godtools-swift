//
//  ArticleAemWebArchiveFileCacheLocation.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleAemWebArchiveFileCacheLocation: FileCacheLocationType {
    
    let directory: String
    let filename: String
    let fileExtension: String?
    
    init(godToolsResource: GodToolsResource, aemImportUrl: URL) {
        
        directory = godToolsResource.resourceId + "/" + godToolsResource.languageCode
        self.filename = aemImportUrl.lastPathComponent
        self.fileExtension = nil
    }
}
