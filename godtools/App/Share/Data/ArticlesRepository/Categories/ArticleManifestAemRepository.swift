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
    private let sharedUserDefaultsCache: SharedUserDefaultsCache
        
    init(downloader: ArticleAemDownloader, cache: ArticleAemCache, categoryArticlesCache: RealmCategoryArticlesCache, sharedUserDefaultsCache: SharedUserDefaultsCache) {
        
        self.categoryArticlesCache = categoryArticlesCache
        self.sharedUserDefaultsCache = sharedUserDefaultsCache
        
        super.init(downloader: downloader, cache: cache)
    }
    
    private func getSyncInvalidatorId(translationId: String) -> String {
        let prefix: String = "\(String(describing: ArticleManifestAemRepository.self)).syncInvalidator.id"
        return prefix + translationId
    }
    
    func getCategoryArticles(categoryId: String, languageCode: String) -> [CategoryArticleModel] {
        
        return categoryArticlesCache.getCategoryArticles(categoryId: categoryId, languageCode: languageCode)
    }
    
    func getCategoryArticlesPublisher(categoryId: String, languageCode: String) -> AnyPublisher<[CategoryArticleModel], Never> {
        
        return categoryArticlesCache.getCategoryArticlesPublisher(categoryId: categoryId, languageCode: languageCode)
            .eraseToAnyPublisher()
    }
    
    func downloadAndCacheManifestAemUrisPublisher(manifest: Manifest, translationId: String, languageCode: String, downloadCachePolicy: ArticleAemDownloaderCachePolicy, sendRequestPriority: SendRequestPriority, forceFetchFromRemote: Bool = false) -> AnyPublisher<ArticleAemRepositoryResult, Never> {
                
        let syncInvalidator = SyncInvalidator(
            id: getSyncInvalidatorId(translationId: translationId),
            timeInterval: .days(day: 5),
            userDefaultsCache: sharedUserDefaultsCache
        )
        
        let shouldSync: Bool = syncInvalidator.shouldSync
        
        guard syncInvalidator.shouldSync || forceFetchFromRemote else {
            return Just(ArticleAemRepositoryResult.emptyResult())
                .eraseToAnyPublisher()
        }
        
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
                
                if cacheErrors.isEmpty {
                    syncInvalidator.didSync()
                }
                
                return result
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
