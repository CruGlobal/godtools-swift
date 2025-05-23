//
//  ArticleAemRepository.swift
//  godtools
//
//  Created by Robert Eldredge on 3/1/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import Combine

open class ArticleAemRepository: NSObject {
    
    let downloader: ArticleAemDownloader
    let cache: ArticleAemCache
    
    init(downloader: ArticleAemDownloader, cache: ArticleAemCache) {
        
        self.downloader = downloader
        self.cache = cache
        
        super.init()
    }
    
    func observeArticleAemCacheObjectsChangedPublisher() -> AnyPublisher<Void, Never> {
        return cache.observeArticleAemCacheObjectsChangedPublisher()
            .eraseToAnyPublisher()
    }
    
    func getAemCacheObjectsPublisher(aemUris: [String]) -> AnyPublisher<[ArticleAemCacheObject], Never> {
        
        return cache.getAemCacheObjectsPublisher(aemUris: aemUris)
            .eraseToAnyPublisher()
    }
    
    func getAemCacheObject(aemUri: String) -> ArticleAemCacheObject? {
        return cache.getAemCacheObject(aemUri: aemUri)
    }
    
    func downloadAndCachePublisher(aemUris: [String], downloadCachePolicy: ArticleAemDownloaderCachePolicy, sendRequestPriority: SendRequestPriority) -> AnyPublisher<ArticleAemRepositoryResult, Never> {
        
        let aemUrisNeedingUpdate: [String]

        switch downloadCachePolicy {
            
        case .fetchFromCacheUpToNextHour:
            aemUrisNeedingUpdate = filterAemUrisByLastUpdate(aemUris: aemUris)
        case .ignoreCache:
            aemUrisNeedingUpdate = aemUris
        }
        
        return downloader.downloadPublisher(
            aemUris: aemUrisNeedingUpdate,
            downloadCachePolicy: downloadCachePolicy,
            sendRequestPriority: sendRequestPriority
        )
        .flatMap { (downloaderResult: ArticleAemDownloaderResult) -> AnyPublisher<ArticleAemRepositoryResult, Never> in
            
            return self.cache.storeAemDataObjectsPublisher(
                aemDataObjects: downloaderResult.aemDataObjects,
                sendRequestPriority: sendRequestPriority
            )
            .map { (cacheResult: ArticleAemCacheResult) in
                
                return ArticleAemRepositoryResult(
                    downloaderResult: downloaderResult,
                    cacheResult: cacheResult
                )
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    private func filterAemUrisByLastUpdate(aemUris: [String]) -> [String] {
        
        var aemUrisNeedingUpdate: [String] = Array()
        
        let secondsInDay: Double = 60 * 60 * 24
        
        for aemUri in aemUris {
            
            let shouldUpdateAemUri: Bool
            
            if let aemCacheObject = cache.getAemCacheObject(aemUri: aemUri) {
                
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
