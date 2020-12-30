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
    
    func deleteWebArchiveDirectory(resourceId: String, languageCode: String) -> Error? {
        
        var error: Error?
        
        let webArchiveCacheLocation = ArticleAemWebArchiveFileCacheLocation(
            resourceId: resourceId,
            languageCode: languageCode,
            filename: ""
        )
        
        var webArchiveDirectoryUrl: URL?
                
        switch getRootDirectory() {
        case .success(let rootDirectoryUrl):
            webArchiveDirectoryUrl = rootDirectoryUrl.appendingPathComponent(webArchiveCacheLocation.directory)
        case .failure(let getWebArchiveRootDirectoryError):
            error = getWebArchiveRootDirectoryError
        }
        
        if let webArchiveDirectoryUrl = webArchiveDirectoryUrl {
            error = removeItem(url: webArchiveDirectoryUrl)
        }
        
        return error
    }
}
