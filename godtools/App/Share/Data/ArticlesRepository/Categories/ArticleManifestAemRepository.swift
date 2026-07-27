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
    
    private let categoryArticlesCache: CategoryArticlesCacheInterface
    private let syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface
        
    init(
        downloader: ArticleAemDownloader,
        cache: ArticleAemCacheInterface,
        categoryArticlesCache: CategoryArticlesCacheInterface,
        syncInvalidatorPersistence: SyncInvalidatorPersistenceInterface
    ) {
        
        self.categoryArticlesCache = categoryArticlesCache
        self.syncInvalidatorPersistence = syncInvalidatorPersistence
        
        super.init(downloader: downloader, cache: cache)
    }
    
    private func getSyncInvalidatorId(translationId: String) -> String {
        let prefix: String = "\(String(describing: ArticleManifestAemRepository.self)).syncInvalidator.id"
        return prefix + translationId
    }
    
    func getCategoryArticles(categoryId: String, languageCode: String) async throws -> [CategoryArticleDataModel] {
        
        return try await categoryArticlesCache.getCategoryArticles(categoryId: categoryId, languageCode: languageCode)
    }
    
    func downloadAndCacheManifestAemUris(
        manifest: Manifest,
        translationId: String,
        languageCode: String,
        downloadCachePolicy: ArticleAemDownloaderCachePolicy,
        requestPriority: RequestPriority,
        forceFetchFromRemote: Bool = false
    ) async throws -> ArticleAemDownload {
        
        let syncInvalidator = SyncInvalidator(
            id: getSyncInvalidatorId(translationId: translationId),
            timeInterval: .days(day: 5),
            persistence: syncInvalidatorPersistence
        )
                
        guard syncInvalidator.shouldSync || forceFetchFromRemote else {
            return ArticleAemDownload.emptyValue
        }
        
        let aemUris: [String] = manifest.aemImports.map { $0.absoluteString }
        
        let download: ArticleAemDownload = try await super.downloadAndCache(
            aemUris: aemUris,
            downloadCachePolicy: downloadCachePolicy,
            requestPriority: requestPriority
        )
        
        let categories: [ManifestCategory] = manifest.categories.compactMap {
            
            guard let id = $0.id else {
                return nil
            }
            
            return ManifestCategory(
                id: id,
                aemTags: $0.aemTags
            )
        }
        
        _ = await categoryArticlesCache.storeAemDataObjectsForCategories(
            categories: categories,
            languageCode: languageCode,
            aemDataObjects: download.aemDataObjects
        )
        
        if download.errors.isEmpty {
            syncInvalidator.didSync()
        }
        
        return download
    }
}
