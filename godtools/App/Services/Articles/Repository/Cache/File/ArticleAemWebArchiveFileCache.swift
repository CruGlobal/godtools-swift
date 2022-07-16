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
    
    required init() {
                
        super.init(rootDirectory: ArticleAemWebArchiveFileCache.rootDirectoryName)
        
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
    
    func logArticles() {
        
        let rootDirectoryResult = getRootDirectory()
        
        switch rootDirectoryResult {
        
        case .success(let rootDirectoryUrl):
            
            let articlesDirectory: URL = rootDirectoryUrl.appendingPathComponent("webarchives")
            
            do {
                
                let contents: [String] = try fileManager.contentsOfDirectory(atPath: articlesDirectory.path)
                
                print("\n Articles File Cache - Root Directory Contents")
                for content in contents {
                    print("  content: \(content)")
                }
            }
            catch let error {
                print("\n Failed to fetch contents of root directory with url: \(rootDirectoryUrl)")
            }
            
        case .failure( _):
            break
        }
    }
}
