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
        
        do {
            try deleteLegacyArticlesDirectory()
        }
        catch let error {
            assertionFailure("Failed to delete legacy articles directory.")
        }
    }
    
    private func deleteLegacyArticlesDirectory() throws {
                
        let legacyDirectoryName: String = "articles_webarchives"
        
        let documentsDirectory = try getUserDocumentsDirectory()
        
        let legacyDirectory: URL = documentsDirectory.appendingPathComponent(legacyDirectoryName)
        
        _ = try removeItem(url: legacyDirectory)
    }
}
