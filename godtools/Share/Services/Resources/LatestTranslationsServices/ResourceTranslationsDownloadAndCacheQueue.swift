//
//  ResourceTranslationsDownloadAndCacheQueue.swift
//  godtools
//
//  Created by Levi Eggert on 5/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourceTranslationsDownloadAndCacheQueue {
        
    private let translationsApi: TranslationsApiType
    private let latestTranslationsCache: ResourcesLatestTranslationsFileCache
    
    required init(translationsApi: TranslationsApiType, latestTranslationsCache: ResourcesLatestTranslationsFileCache) {
        
        self.translationsApi = translationsApi
        self.latestTranslationsCache = latestTranslationsCache
    }
    
    deinit {

    }
    
    func downloadAndCacheResourceTranslations(resources: [GodToolsResource]) -> OperationQueue {
        
        let queue = OperationQueue()
        
        var operations: [ResourceTranslationDownloadAndCacheOperation] = Array()
        
        var progress: Double = 0
        var completedOperationCount: Int = 0
        var totalOperationCount: Int = 0
        
        for resource in resources {
            
            let operation = ResourceTranslationDownloadAndCacheOperation(
                resource: resource,
                translationsApi: translationsApi,
                translationsCache: latestTranslationsCache
            )
            
            operation.completionHandler { [weak self] (result: Result<ResourceTranslationDownloadAndCacheOperationResult, ResourceTranslationDownloadAndCacheOperationError>) in
                
                switch result {
                case .success(let operationResult):
                    break
                case .failure(let error):
                    break
                }
                
                completedOperationCount += 1
                progress = Double(completedOperationCount / totalOperationCount)
                
                if operations.isEmpty {
                    
                    progress = 1
                    
                    // TODO: Complete.
                }
            }
            
            operations.append(operation)
        }
        
        if !operations.isEmpty {
            
            totalOperationCount = operations.count
            queue.addOperations(operations, waitUntilFinished: false)
        }
        else {
            
        }
        
        return queue
    }
}
