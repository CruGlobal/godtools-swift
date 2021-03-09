//
//  ArticleAemRepository.swift
//  godtools
//
//  Created by Robert Eldredge on 3/1/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ArticleAemRepository {
    
    private let importDownloader: ArticleAemImportDownloader
    
    required init(importDownloader: ArticleAemImportDownloader) {
        
        self.importDownloader = importDownloader
    }
    
    func getArticleArchiveUrl(filename: String) -> URL? {
        return importDownloader.getWebArchiveUrl(location: ArticleAemWebArchiveFileCacheLocation(filename: filename))
    }
    
    func getArticleAem(aemUri: ArticleAemUri, cache: ((_ articleAem: ArticleAemModel) -> Void), downloadStarted: (() -> Void), downloadFinished: ((_ result: Result<ArticleAemModel, Error>) -> Void)) {
        
        //TODO: create ArticleAemArchiver and ArticleAemDownloader to replace ArticleAemImportDownloader ~Robert
        // If the article aem is cached to the filesystem, go ahead and call the cache closure and return immediately.

        // Otherwise, we will download and parse the aem uri and cache the web archive to the filesystem.
        importDownloader.downloadAndCache(translationZipFile: nil, aemImportSrcs: [aemUri.uriString])
    }
}
