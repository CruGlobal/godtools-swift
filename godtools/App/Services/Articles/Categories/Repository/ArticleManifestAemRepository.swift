//
//  ArticleManifestAemRepository.swift
//  godtools
//
//  Created by Levi Eggert on 4/2/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

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
    
    func getCategoryArticles(categoryId: String, languageCode: String) -> [CategoryArticleModel] {
        
        let realmCategoryArticles: [RealmCategoryArticle] = categoryArticlesCache.getCategoryArticles(categoryId: categoryId, languageCode: languageCode)
        
        return realmCategoryArticles.map({CategoryArticleModel(realmModel: $0)})
    }
    
    func downloadAndCacheManifestAemUris(manifest: Manifest, languageCode: String, forceDownload: Bool, completion: @escaping ((_ result: ArticleAemRepositoryResult) -> Void)) -> ArticleManifestDownloadArticlesReceipt {
                
        let receipt = ArticleManifestDownloadArticlesReceipt()
        
        let aemUris: [String] = manifest.aemImports.map({$0.absoluteString})
        
        let categories: [ArticleCategory] = manifest.categories.map({
            ArticleCategory(
                aemTags: Array($0.aemTags),
                id: $0.id ?? ""
            )
        })
        
        let downloadQueue = downloadAndCache(aemUris: aemUris, forceDownload: forceDownload) { [weak self] (result: ArticleAemRepositoryResult) in
            
            guard let repository = self else {
                return
            }
            
            let aemDataObjects: [ArticleAemData] = result.downloaderResult.aemDataObjects
            
            repository.categoryArticlesCache.storeAemDataObjectsForCategories(categories: categories, languageCode: languageCode, aemDataObjects: aemDataObjects) { (cacheError: [Error]) in
                
                completion(result)
                
                receipt.downloadCompleted(result: result)
            }
        }
        
        receipt.downloadStarted(downloadQueue: downloadQueue)
        
        return receipt
    }
}
