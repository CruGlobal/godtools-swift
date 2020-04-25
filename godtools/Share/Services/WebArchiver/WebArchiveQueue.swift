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
    
    func archive(urls: [URL], didArchivePlistData: @escaping ((_ result: Result<Data?, Error>) -> Void), complete: (() -> Void)? = nil) -> OperationQueue {
        
        let queue = OperationQueue()
        
        var operations: [WebArchiveOperation] = Array()
        
        for url in urls {
            
            let operation = WebArchiveOperation(session: session, url: url)
            
            operation.completionHandler { [weak self] (result: Result<Data?, Error>) in
                
                didArchivePlistData(result)
                
                let finished: Bool = queue.operations.isEmpty
                
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
