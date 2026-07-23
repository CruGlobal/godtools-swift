//
//  ArticleAemRepository.swift
//  godtools
//
//  Created by Robert Eldredge on 3/1/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import RequestOperation

open class ArticleAemRepository: NSObject {
    
    private let cache: ArticleAemCache
    private let downloader: ArticleAemDownloaderInterface
    
    init(downloader: ArticleAemDownloader, cache: ArticleAemCache) {
        
        self.downloader = downloader
        self.cache = cache
        
        super.init()
    }
    
    func getArticleAemDataObjects() async throws -> [ArticleAemData] {
        return try await cache.getArticleAemDataObjects()
    }
    
    func getAemCacheObject(aemUri: String) -> ArticleAemCacheObject? {
        do {
            return try cache.getAemCacheObject(aemUri: aemUri)
        }
        catch _ {
            return nil
        }
    }
    
    func getAemCacheObjects(aemUris: [String]) throws -> [ArticleAemCacheObject] {
        
        return try cache.getAemCacheObjects(aemUris: aemUris)
    }
    
    func downloadAndCache(
        aemUris: [String],
        downloadCachePolicy: ArticleAemDownloaderCachePolicy,
        requestPriority: RequestPriority
    ) async throws -> ArticleAemDownload {
        
        let aemUrisNeedingUpdate: [String]

        switch downloadCachePolicy {
            
        case .fetchFromCacheUpToNextHour:
            aemUrisNeedingUpdate = filterAemUrisByLastUpdate(aemUris: aemUris)
        case .ignoreCache:
            aemUrisNeedingUpdate = aemUris
        }
        
        let aemDataObjects: [ArticleAemData] = await downloader.download(
            aemUris: aemUrisNeedingUpdate,
            downloadCachePolicy: downloadCachePolicy,
            requestPriority: requestPriority
        )
                
        let webArchiveErrors: [Error] = try await cache.storeAemDataObjects(
            aemDataObjects: aemDataObjects,
            requestPriority: requestPriority
        ).compactMap { $0.error }
        
        return ArticleAemDownload(aemDataObjects: aemDataObjects, webArchiveErrors: webArchiveErrors)
    }
    
    private func filterAemUrisByLastUpdate(aemUris: [String]) -> [String] {
        
        var aemUrisNeedingUpdate: [String] = Array()
        
        let secondsInDay: Double = 60 * 60 * 24
        
        for aemUri in aemUris {
            
            let shouldUpdateAemUri: Bool
            
            do {
                
                if let aemCacheObject = try cache.getAemCacheObject(aemUri: aemUri) {
                    
                    let lastUpdatedAt: Date = aemCacheObject.aemData.updatedAt
                    let secondsSinceLastUpdate: Double = Date().timeIntervalSince(lastUpdatedAt)
                    
                    shouldUpdateAemUri = secondsSinceLastUpdate >= secondsInDay
                }
                else {
                    shouldUpdateAemUri = true
                }
            }
            catch _ {
                shouldUpdateAemUri = true
            }
            
            guard shouldUpdateAemUri else {
                continue
            }
            
            aemUrisNeedingUpdate.append(aemUri)
        }
        
        return aemUrisNeedingUpdate
    }
}
