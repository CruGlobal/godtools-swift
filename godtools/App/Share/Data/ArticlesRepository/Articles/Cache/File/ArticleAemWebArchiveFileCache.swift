//
//  ArticleAemWebArchiveFileCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

final class ArticleAemWebArchiveFileCache: Sendable {
    
    private static let rootDirectoryName: String = "articles"
    
    let fileCache: FileCache
    
    init() {
        
        fileCache = FileCache(rootDirectoryName: ArticleAemWebArchiveFileCache.rootDirectoryName)
                        
        Task {
            
            do {
                try await deleteLegacyArticlesDirectory()
            }
            catch _ {

            }
        }
    }
    
    private func deleteLegacyArticlesDirectory() async throws {
                
        let legacyDirectoryName: String = "articles_webarchives"
        
        let documentsDirectory = try await fileCache.getUserDocumentsDirectory()
        
        let legacyDirectory: URL = documentsDirectory.appendingPathComponent(legacyDirectoryName)
        
        _ = try await fileCache.removeItem(url: legacyDirectory)
    }
}
