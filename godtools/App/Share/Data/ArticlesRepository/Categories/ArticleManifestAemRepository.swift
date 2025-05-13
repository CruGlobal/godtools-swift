//
//  ArticleManifestAemRepository.swift
//  godtools
//
//  Created by Levi Eggert on 4/2/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import Combine

class ArticleManifestAemRepository: ArticleAemRepository {
    
    private let categoryArticlesCache: RealmCategoryArticlesCache
        
    init(downloader: ArticleAemDownloader, cache: ArticleAemCache, categoryArticlesCache: RealmCategoryArticlesCache) {
        
        self.categoryArticlesCache = categoryArticlesCache
        
        super.init(downloader: downloader, cache: cache)
    }
    
    func getCategoryArticles(categoryId: String, languageCode: String) -> [CategoryArticleModel] {
        
        return categoryArticlesCache.getCategoryArticles(categoryId: categoryId, languageCode: languageCode)
    }
    
    func downloadAndCacheManifestAemUrisPublisher(manifest: Manifest, languageCode: String, downloadCachePolicy: ArticleAemDownloaderCachePolicy, sendRequestPriority: SendRequestPriority) -> AnyPublisher<ArticleAemRepositoryResult, Never> {
        
        let aemUris: [String] = manifest.aemImports.map({$0.absoluteString})
        
        let categories: [ArticleCategory] = manifest.categories.map({
            ArticleCategory(
                aemTags: Array($0.aemTags),
                id: $0.id ?? ""
            )
        })
        
        return super.downloadAndCachePublisher(
            aemUris: aemUris,
            downloadCachePolicy: downloadCachePolicy,
            sendRequestPriority: sendRequestPriority
        )
        .flatMap { (result: ArticleAemRepositoryResult) -> AnyPublisher<ArticleAemRepositoryResult, Never> in
                                
            return self.categoryArticlesCache.storeAemDataObjectsForCategoriesPublisher(
                categories: categories,
                languageCode: languageCode,
                aemDataObjects: result.downloaderResult.aemDataObjects
            )
            .map { (cacheErrors: [Error]) in
                return result
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
