//
//  ArticleAemDownloader.swift
//  godtools
//
//  Created by Levi Eggert on 4/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RequestOperation

class ArticleAemDownloader {
            
    private let session: URLSession
    private let maxAemJsonTreeLevels: Int = 9999
        
    init(ignoreCacheSession: IgnoreCacheSession) {
        
        self.session = ignoreCacheSession.session
    }
    
    func download(aemUris: [String], downloadCachePolicy: ArticleAemDownloadOperationCachePolicy, completion: @escaping ((_ result: ArticleAemDownloaderResult) -> Void)) -> OperationQueue {
                        
        let queue = OperationQueue()
                
        var operations: [ArticleAemDownloadOperation] = Array()
                
        var aemDataObjects: [ArticleAemData] = Array()
        var aemDownloadErrors: [ArticleAemDownloadOperationError] = Array()
                        
        for aemUri in aemUris {
            
            let operation = ArticleAemDownloadOperation(
                session: session,
                aemUri: aemUri,
                maxAemJsonTreeLevels: maxAemJsonTreeLevels,
                cachePolicy: downloadCachePolicy
            )
            
            operations.append(operation)
            
            operation.completionHandler { (response: RequestResponse, result: Result<ArticleAemData, ArticleAemDownloadOperationError>) in
                
                switch result {
                    
                case .success(let aemData):
                    aemDataObjects.append(aemData)
                    
                case .failure(let aemDownloadError):
                    aemDownloadErrors.append(aemDownloadError)
                }
                                                
                if queue.operations.isEmpty {
                    
                    let result = ArticleAemDownloaderResult(
                        aemDataObjects: aemDataObjects,
                        aemDownloadErrors: aemDownloadErrors
                    )
                    
                    completion(result)
                }
            }
        }
        
        if !operations.isEmpty {
            queue.addOperations(operations, waitUntilFinished: false)
        }
        else {
            completion(ArticleAemDownloaderResult(aemDataObjects: [], aemDownloadErrors: []))
        }
        
        return queue
    }
}
