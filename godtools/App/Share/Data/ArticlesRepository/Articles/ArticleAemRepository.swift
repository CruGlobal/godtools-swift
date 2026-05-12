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
    private let downloader: ArticleAemDownloader
    
    init(downloader: ArticleAemDownloader, cache: ArticleAemCache) {
        
        self.downloader = downloader
        self.cache = cache
        
        super.init()
    }
    
    @available(*, deprecated) // Remove and use throws. ~Levi
    func getAemCacheObjectNonThrowing(aemUri: String) -> ArticleAemCacheObject? {
        do {
            return try cache.getAemCacheObject(aemUri: aemUri)
        }
        catch _ {
            return nil
        }
    }
    
    func getAemCacheObject(aemUri: String) throws -> ArticleAemCacheObject? {
        return try cache.getAemCacheObject(aemUri: aemUri)
    }
    
    func getAemCacheObjects(aemUris: [String]) throws -> [ArticleAemCacheObject] {
        
        return try cache.getAemCacheObjects(aemUris: aemUris)
    }
    
    func downloadAndCache(aemUris: [String], downloadCachePolicy: ArticleAemDownloaderCachePolicy, requestPriority: RequestPriority) async throws -> ArticleAemDownload {
        
        let aemUrisNeedingUpdate: [String]

        switch downloadCachePolicy {
            
        case .fetchFromCacheUpToNextHour:
            aemUrisNeedingUpdate = try filterAemUrisByLastUpdate(aemUris: aemUris)
        case .ignoreCache:
            aemUrisNeedingUpdate = aemUris
        }
        
        let download: ArticleAemDownload = await downloader.download(
            aemUris: aemUrisNeedingUpdate,
            downloadCachePolicy: downloadCachePolicy,
            requestPriority: requestPriority
        )
        
        try await cache.storeAemDataObjects(
            aemDataObjects: download.aemDataObjects,
            requestPriority: requestPriority
        )
        
        return download
    }
    
    private func filterAemUrisByLastUpdate(aemUris: [String]) throws -> [String] {
        
        var aemUrisNeedingUpdate: [String] = Array()
        
        let secondsInDay: Double = 60 * 60 * 24
        
        for aemUri in aemUris {
            
            let shouldUpdateAemUri: Bool
            
            if let aemCacheObject = try cache.getAemCacheObject(aemUri: aemUri) {
                
                let lastUpdatedAt: Date = aemCacheObject.aemData.updatedAt
                let secondsSinceLastUpdate: Double = Date().timeIntervalSince(lastUpdatedAt)
                
                shouldUpdateAemUri = secondsSinceLastUpdate >= secondsInDay
            }
            else {
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
