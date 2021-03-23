//
//  ArticleAemRepository.swift
//  godtools
//
//  Created by Robert Eldredge on 3/1/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ArticleAemRepository: NSObject, ArticleAemRepositoryType {
    
    private let importDownloader: ArticleAemImportDownloader
    
    required init(importDownloader: ArticleAemImportDownloader) {
        
        self.importDownloader = importDownloader
    }
    
    func getArticleArchiveUrl(filename: String) -> URL? {
        
        let webArchiveLocation = ArticleAemWebArchiveFileCacheLocation(filename: filename)
        
        return importDownloader.getWebArchiveUrl(location: webArchiveLocation)
    }
    
    func getArticleAem(aemUri: ArticleAemUri, cache: @escaping ((_ articleAem: ArticleAemModel) -> Void), downloadStarted: @escaping (() -> Void), downloadFinished: @escaping ((_ result: ArticleAemModel) -> Void)) {
        
        //TODO: create ArticleAemArchiver and ArticleAemDownloader to replace ArticleAemImportDownloader ~Robert
        // If the article aem is cached to the filesystem, go ahead and call the cache closure and return immediately.

        // Otherwise, we will download and parse the aem uri and cache the web archive to the filesystem.
        let receipt = importDownloader.downloadAndCache(aemImportSrcs: [aemUri.uriString])
                
        receipt.started.addObserver(self) { (isStarted: Bool) in
            if isStarted {
                downloadStarted()
            }
        }
        
        receipt.completed.addObserver(self) { (result: ArticleAemImportDownloaderResult) in
            let data = result.articleAemImportDataObjects[0]

            guard let url = URL(string: data.webUrl) else { return }
            
            let articleAemModel = ArticleAemModel(aemUri: ArticleAemUri(aemUri: data.aemUri), importData: data, webArchiveUrl: url)
                        
            downloadFinished(articleAemModel)
        }
    }
}
