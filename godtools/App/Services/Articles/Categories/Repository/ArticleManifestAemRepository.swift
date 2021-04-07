//
//  ArticleManifestAemRepository.swift
//  godtools
//
//  Created by Levi Eggert on 4/2/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ArticleManifestAemRepository: NSObject, ArticleAemRepositoryType {
    
    private let categoryArticlesCache: RealmCategoryArticlesCache
    
    let downloader: ArticleAemDownloader
    let cache: ArticleAemCache
    
    required init(downloader: ArticleAemDownloader, cache: ArticleAemCache, realmDatabase: RealmDatabase) {
        
        self.categoryArticlesCache = RealmCategoryArticlesCache(realmDatabase: realmDatabase)
        self.downloader = downloader
        self.cache = cache
        
        super.init()
    }
    
    func getCategoryArticles(category: ArticleCategory, languageCode: String) -> [CategoryArticleModel] {
        
        let realmCategoryArticles: [RealmCategoryArticle] = categoryArticlesCache.getCategoryArticles(category: category, languageCode: languageCode)
        
        return realmCategoryArticles.map({CategoryArticleModel(realmModel: $0)})
    }
    
    func downloadAndCacheManifestAemUris(manifest: ArticleManifestType, languageCode: String, forceDownload: Bool, completion: @escaping ((_ result: ArticleAemRepositoryResult) -> Void)) -> ArticleManifestDownloadArticlesReceipt {
                
        let receipt = ArticleManifestDownloadArticlesReceipt()
        
        let downloadQueue = downloadAndCache(aemUris: manifest.aemUris, forceDownload: forceDownload) { [weak self] (result: ArticleAemRepositoryResult) in
            
            guard let repository = self else {
                return
            }
            
            let aemDataObjects: [ArticleAemData] = result.downloaderResult.aemDataObjects
            
            repository.categoryArticlesCache.storeAemDataObjectsForManifest(manifest: manifest, languageCode: languageCode, aemDataObjects: aemDataObjects) { (cacheError: [Error]) in
                
                completion(result)
                
                receipt.downloadCompleted(result: result)
            }
        }
        
        receipt.downloadStarted(downloadQueue: downloadQueue)
        
        return receipt
    }
}
