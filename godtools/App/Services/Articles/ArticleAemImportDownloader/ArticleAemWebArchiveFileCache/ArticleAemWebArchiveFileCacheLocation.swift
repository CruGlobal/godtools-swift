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
    
    init(filename: String) {
        
        self.directory = "articles"
        self.filename = filename
        self.fileExtension = "webarchive"
    }
}
