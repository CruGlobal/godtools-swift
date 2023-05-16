//
//  ArticleAemRepositoryType.swift
//  godtools
//
//  Created by Robert Eldredge on 3/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol ArticleAemRepositoryType: NSObject {
    
    var downloader: ArticleAemDownloader { get }
    var cache: ArticleAemCache { get }
    
    func getAemCacheObject(aemUri: String) -> ArticleAemCacheObject?
    func downloadAndCache(aemUris: [String], forceDownload: Bool, completion: @escaping ((_ result: ArticleAemRepositoryResult) -> Void)) -> OperationQueue
}

extension ArticleAemRepositoryType {
    
    func getAemCacheObjectsOnBackgroundThread(aemUris: [String], completion: @escaping ((_ aemCacheObjects: [ArticleAemCacheObject]) -> Void)) {
        
        return cache.getAemCacheObjectsOnBackgroundThread(aemUris: aemUris, completion: completion)
    }
    
    func getAemCacheObject(aemUri: String) -> ArticleAemCacheObject? {
        
        return cache.getAemCacheObjectOnCurrentThread(aemUri: aemUri)
    }
    
    func downloadAndCache(aemUris: [String], forceDownload: Bool = false, completion: @escaping ((_ result: ArticleAemRepositoryResult) -> Void)) -> OperationQueue {
        
        let aemUrisNeedingUpdate: [String]
        let downloadCachePolicy: ArticleAemDownloadOperationCachePolicy
        
        if forceDownload {
            aemUrisNeedingUpdate = aemUris
            downloadCachePolicy = .ignoreCache
        }
        else {
            aemUrisNeedingUpdate = filterAemUrisByLastUpdate(aemUris: aemUris)
            downloadCachePolicy = .fetchFromCacheUpToNextHour
        }
        
        return downloader.download(aemUris: aemUrisNeedingUpdate, downloadCachePolicy: downloadCachePolicy) { [weak self] (downloaderResult: ArticleAemDownloaderResult) in
            
            guard let repository = self else {
                return
            }
            
            let aemDataObjects: [ArticleAemData] = downloaderResult.aemDataObjects
            
            repository.cache.storeAemDataObjects(aemDataObjects: aemDataObjects, didStartWebArchiveClosure: { (webArchiveOperationQueue: OperationQueue) in
                
            }, completion: { (cacheResult: ArticleAemCacheResult) in
                
                let result = ArticleAemRepositoryResult(downloaderResult: downloaderResult, cacheResult: cacheResult)
                
                completion(result)
            })
        }
    }
    
    private func filterAemUrisByLastUpdate(aemUris: [String]) -> [String] {
        
        var aemUrisNeedingUpdate: [String] = Array()
        
        let secondsInDay: Double = 60 * 60 * 24
        
        for aemUri in aemUris {
            
            let shouldUpdateAemUri: Bool
            
            if let aemCacheObject = cache.getAemCacheObjectOnCurrentThread(aemUri: aemUri) {
                
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
