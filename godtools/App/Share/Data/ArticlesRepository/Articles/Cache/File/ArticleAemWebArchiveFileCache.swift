//
//  ArticleAemWebArchiveFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleAemWebArchiveFileCache: FileCache {
    
    private static let rootDirectoryName: String = "articles"
    
    init() {
                
        super.init(rootDirectory: ArticleAemWebArchiveFileCache.rootDirectoryName)
        
        deleteLegacyArticlesDirectory()
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
