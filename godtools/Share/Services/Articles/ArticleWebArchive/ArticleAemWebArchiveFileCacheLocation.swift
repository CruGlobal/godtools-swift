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
    
    init(resource: DownloadedResource, language: Language, filename: String, fileExtension: String?) {
        
        directory = resource.remoteId + "/" + language.code + "/" + "archives"
        self.filename = filename
        self.fileExtension = fileExtension
    }
}
