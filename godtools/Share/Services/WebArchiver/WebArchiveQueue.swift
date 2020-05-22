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
    
    func archive(url: URL, complete: @escaping ((_ result: Result<WebArchiveOperationResult, WebArchiveOperationError>) -> Void)) -> OperationQueue {
        
        let singleQueue = OperationQueue()
        
        let operation = WebArchiveOperation(session: session, url: url)
        
        operation.completionHandler { [weak self] (result: Result<WebArchiveOperationResult, WebArchiveOperationError>) in
            
            complete(result)
        }
        
        singleQueue.addOperations([operation], waitUntilFinished: false)
        
        return singleQueue
    }
    
    func archive(urls: [URL], didArchivePlistData: @escaping ((_ result: Result<WebArchiveOperationResult, WebArchiveOperationError>) -> Void), complete: (() -> Void)? = nil) -> OperationQueue {
        
        let queue = OperationQueue()
        
        var operations: [WebArchiveOperation] = Array()
        
        let queueRef = queue
        
        for url in urls {
            
            let operation = WebArchiveOperation(session: session, url: url)
            
            operation.completionHandler { [weak self] (result: Result<WebArchiveOperationResult, WebArchiveOperationError>) in
                
                didArchivePlistData(result)
                
                let finished: Bool = queueRef.operations.isEmpty
                
                if finished, let complete = complete {
                    complete()
                }
            }
            
            operations.append(operation)
        }
        
        if operations.count > 0 {
            queue.addOperations(operations, waitUntilFinished: false)
        }
        else if let complete = complete {
            complete()
        }
        
        return queue
    }
}
