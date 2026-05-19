//
//  ArticleAemWebArchiveFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

final class ArticleAemWebArchiveFileCache {
    
    private static let rootDirectoryName: String = "articles"
    
    let fileCache: FileCache
    
    init() {
        
        fileCache = FileCache(rootDirectory: ArticleAemWebArchiveFileCache.rootDirectoryName)
                        
        do {
            try deleteLegacyArticlesDirectory()
        }
        catch _ {

        }
    }
    
    private func deleteLegacyArticlesDirectory() throws {
                
        let legacyDirectoryName: String = "articles_webarchives"
        
        let documentsDirectory = try fileCache.getUserDocumentsDirectory()
        
        let legacyDirectory: URL = documentsDirectory.appendingPathComponent(legacyDirectoryName)
        
        _ = try fileCache.removeItem(url: legacyDirectory)
    }
}
