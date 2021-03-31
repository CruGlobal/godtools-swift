//
//  ArticleManifestAemDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 3/31/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ArticleManifestAemDownloader: NSObject {
    
    private let categoryArticlesCache: RealmCategoryArticlesCache
    private let downloader: ArticleAemImportDownloader
    
    required init(realmDatabase: RealmDatabase, downloader: ArticleAemImportDownloader) {
        
        self.categoryArticlesCache = RealmCategoryArticlesCache(realmDatabase: realmDatabase)
        self.downloader = downloader
        
        super.init()
    }
    
    func getCategoryArticles(category: ArticleCategory, languageCode: String) -> [CategoryArticleModel] {
        
        let realmCategoryArticles: [RealmCategoryArticle] = categoryArticlesCache.getCategoryArticles(category: category, languageCode: languageCode)
        
        return realmCategoryArticles.map({CategoryArticleModel(realmModel: $0)})
    }
    
    func downloadManifestAemUris(manifest: ArticleManifestType, languageCode: String) -> ArticleManifestAemDownloadReceipt {
        
        let aemUris: [String] = manifest.aemImportSrcs
        
        let aemDownloaderReceipt = downloader.downloadAndCache(aemImportSrcs: aemUris)

        let manifestDownloadReceipt = ArticleManifestAemDownloadReceipt(aemDownloaderReceipt: aemDownloaderReceipt)
        
        aemDownloaderReceipt.completed.addObserver(self) { [weak self] (result: ArticleAemImportDownloaderResult) in
            
            self?.categoryArticlesCache.storeArticleAemDataForManifestCategories(manifest: manifest, languageCode: languageCode, downloadedManifestAemDataImports: result.articleAemImportDataObjects, completion: { (cacheErrors: [Error]) in
                
                manifestDownloadReceipt.completed.accept()
            })
        }
        
        return manifestDownloadReceipt
    }
}
