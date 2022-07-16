//
//  ArticleAemWebArchiveFileCacheLocation.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ArticleAemWebArchiveFileCacheLocation: FileCacheLocationType {
    
    let directory: String = "webarchives"
    let filename: String
    let filePathExtension: String?
    
    init(filename: String) {
        
        self.filename = filename
        self.filePathExtension = "webarchive"
    }
}
