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
    
    func getAemCacheObjectsOnBackgroundThread(aemUris: [String], completion: @escaping ((_ aemCacheObjects: [ArticleAemCacheObject]) -> Void)) {
        
        return cache.getAemCacheObjectsOnBackgroundThread(aemUris: aemUris, completion: completion)
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
        
        print("\n ArticleAemRepository - downloadAndCachePublisher()")
        print("  aemUrisNeedingUpdate: \(aemUrisNeedingUpdate)")
        print("  downloadCachePolicy: \(downloadCachePolicy)")
        
        return downloader.downloadPublisher(
            aemUris: aemUrisNeedingUpdate,
            downloadCachePolicy: downloadCachePolicy,
            sendRequestPriority: sendRequestPriority
        )
        .map { (downloaderResult: ArticleAemDownloaderResult) in
            
            // TODO: GT-2580 cache aemDataObjects repository.cache.storeAemDataObjects. ~Levi
            
            return ArticleAemRepositoryResult(
                downloaderResult: downloaderResult,
                cacheResult: ArticleAemCacheResult(numberOfArchivedObjects: 0, cacheErrorData: [])
            )
        }
        .eraseToAnyPublisher()
    }
    
    // TODO: Remove GT-2580. ~Levi
//    func downloadAndCache(aemUris: [String], forceDownload: Bool = false, completion: @escaping ((_ result: ArticleAemRepositoryResult) -> Void)) -> OperationQueue {
//        
//        let aemUrisNeedingUpdate: [String]
//        let downloadCachePolicy: ArticleAemDownloaderCachePolicy
//        
//        if forceDownload {
//            aemUrisNeedingUpdate = aemUris
//            downloadCachePolicy = .ignoreCache
//        }
//        else {
//            aemUrisNeedingUpdate = filterAemUrisByLastUpdate(aemUris: aemUris)
//            downloadCachePolicy = .fetchFromCacheUpToNextHour
//        }
//        
//        return downloader.download(aemUris: aemUrisNeedingUpdate, downloadCachePolicy: downloadCachePolicy) { [weak self] (downloaderResult: ArticleAemDownloaderResult) in
//            
//            guard let repository = self else {
//                return
//            }
//            
//            let aemDataObjects: [ArticleAemData] = downloaderResult.aemDataObjects
//            
//            repository.cache.storeAemDataObjects(aemDataObjects: aemDataObjects, didStartWebArchiveClosure: { (webArchiveOperationQueue: OperationQueue) in
//                
//            }, completion: { (cacheResult: ArticleAemCacheResult) in
//                
//                let result = ArticleAemRepositoryResult(downloaderResult: downloaderResult, cacheResult: cacheResult)
//                
//                completion(result)
//            })
//        }
//    }
    
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
