//
//  ArticleManifestAemRepository.swift
//  godtools
//
//  Created by Levi Eggert on 4/2/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsShared
import RequestOperation

final class ArticleManifestAemRepository: ArticleAemRepository {
    
    private let categoryArticlesCache: CategoryArticlesCache
    private let syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface
        
    init(downloader: ArticleAemDownloader, cache: ArticleAemCache, categoryArticlesCache: CategoryArticlesCache, syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface) {
        
        self.categoryArticlesCache = categoryArticlesCache
        self.syncInvalidatorPersistence = syncInvalidatorPersistence
        
        super.init(downloader: downloader, cache: cache)
    }
    
    private func getSyncInvalidatorId(translationId: String) -> String {
        let prefix: String = "\(String(describing: ArticleManifestAemRepository.self)).syncInvalidator.id"
        return prefix + translationId
    }
    
    func getCategoryArticles(categoryId: String, languageCode: String) async throws -> [CategoryArticleModel] {
        
        return try await categoryArticlesCache.getCategoryArticles(categoryId: categoryId, languageCode: languageCode)
    }
    
    func downloadAndCacheManifestAemUris(manifest: Manifest, translationId: String, languageCode: String, downloadCachePolicy: ArticleAemDownloaderCachePolicy, requestPriority: RequestPriority, forceFetchFromRemote: Bool = false) async throws {
        
        let syncInvalidator = SyncInvalidator(
            id: getSyncInvalidatorId(translationId: translationId),
            timeInterval: .days(day: 5),
            persistence: syncInvalidatorPersistence
        )
                
        guard syncInvalidator.shouldSync || forceFetchFromRemote else {
            return
        }
        
        let aemUris: [String] = manifest.aemImports.map({$0.absoluteString})
        
        let categories: [ArticleCategory] = manifest.categories.map({
            ArticleCategory(
                aemTags: Array($0.aemTags),
                id: $0.id ?? ""
            )
        })
        
        let aemDataObjects: [ArticleAemData] = try await super.downloadAndCache(
            aemUris: aemUris,
            downloadCachePolicy: downloadCachePolicy,
            requestPriority: requestPriority
        )
        
        let errors: [Error] = await categoryArticlesCache.storeAemDataObjectsForCategories(
            categories: categories,
            languageCode: languageCode,
            aemDataObjects: aemDataObjects
        )
        
        if !errors.isEmpty {
            syncInvalidator.didSync()
        }
    }
}
