//
//  WebArchiveQueue.swift
//  godtools
//
//  Created by Levi Eggert on 4/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class WebArchiveQueue {
    
    private let session: URLSession
        
    required init() {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 60
            
        session = URLSession(configuration: configuration)
    }
    
    deinit {

    }
    
    func archive(urls: [URL], didArchivePlistData: @escaping ((_ result: Result<WebArchiveOperationResult, WebArchiveOperationError>) -> Void), complete: @escaping ((_ webArchiveQueueResult: WebArchiveQueueResult) -> Void)) -> OperationQueue {
        
        let queue = OperationQueue()
        
        var operations: [WebArchiveOperation] = Array()
        
        var successfulArchives: [WebArchiveOperationResult] = Array()
        var failedArchives: [WebArchiveOperationError] = Array()
        
        for url in urls {
            
            let operation = WebArchiveOperation(session: session, url: url)
            
            operation.completionHandler { (result: Result<WebArchiveOperationResult, WebArchiveOperationError>) in
                
                switch result {
                case .success(let operationResult):
                    successfulArchives.append(operationResult)
                case .failure(let operationError):
                    failedArchives.append(operationError)
                }
                
                didArchivePlistData(result)
                                
                if queue.operations.isEmpty {
                   
                    complete(WebArchiveQueueResult(successfulArchives: successfulArchives, failedArchives: failedArchives, totalAttemptedArchives: operations.count))
                }
            }
            
            operations.append(operation)
        }
        
        if !operations.isEmpty {
            queue.addOperations(operations, waitUntilFinished: false)
        }
        else {
            complete(WebArchiveQueueResult(successfulArchives: [], failedArchives: [], totalAttemptedArchives: 0))
        }
        
        return queue
    }
}
