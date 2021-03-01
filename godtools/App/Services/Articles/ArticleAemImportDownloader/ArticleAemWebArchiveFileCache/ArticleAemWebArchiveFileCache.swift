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
                
        super.init(rootDirectory: "articles")
        
        deleteLegacyArticlesDirectory()
    }
    
    required init(rootDirectory: String) {
        fatalError("ArticleAemWebArchiveFileCache: init(rootDirectory: should not be used.  Instead, use init() to initialize with the correct rootDirectory.")
    }
    
    private func deleteLegacyArticlesDirectory() {
                
        let legacyDirectoryName: String = "articles_webarchives"
        
        switch getUserDocumentsDirectory() {
        case .success(let documentsDirectory):
            let legacyDirectory: URL = documentsDirectory.appendingPathComponent(legacyDirectoryName)
            _ = removeItem(url: legacyDirectory)
        case .failure( _):
            break
        }
    }
}
