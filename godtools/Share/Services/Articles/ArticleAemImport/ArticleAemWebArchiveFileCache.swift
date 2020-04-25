//
//  ArticleAemWebArchiveFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleAemWebArchiveFileCache: FileCache<ArticleAemWebArchiveFileCacheLocation> {
    
    required init() {
        super.init(rootDirectory: "articles_webarchives")
    }
    
    required init(rootDirectory: String) {
        fatalError("ArticleAemWebArchiveFileCache: init(rootDirectory: should not be used.  Instead, use init() to initialize with the correct rootDirectory.")
    }
}
