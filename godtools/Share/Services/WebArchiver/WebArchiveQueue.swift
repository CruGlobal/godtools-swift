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
    
    func archive(urls: [URL], didArchivePlistData: @escaping ((_ result: Result<WebArchiveOperationResult, WebArchiveOperationError>) -> Void), complete: @escaping ((_ error: WebArchiveError?) -> Void)) -> OperationQueue {
        
        let queue = OperationQueue()
        
        var operations: [WebArchiveOperation] = Array()
        
        let queueRef = queue
        
        var networkFailed: Bool = false
        var cancelled: Bool = false
        
        for url in urls {
            
            let operation = WebArchiveOperation(session: session, url: url)
            
            operation.completionHandler { [weak self] (result: Result<WebArchiveOperationResult, WebArchiveOperationError>) in
                
                switch result {
                case .success( _):
                    break
                case .failure(let operationError):
                    switch operationError {
                    case .cancelled:
                        cancelled = true
                    case .failedEncodingPlistData( _):
                        break
                    case .failedFetchingHtmlDocument( _):
                        break
                    case .failedToParseHtmlDocument( _):
                        break
                    case .invalidHost( _):
                        break
                    case .invalidMimeType( _):
                        break
                    case .noNetworkConnection:
                        networkFailed = true
                    case .responseError( _):
                        break
                    case .unknownError( _):
                        break
                    }
                }
                
                didArchivePlistData(result)
                                
                if queueRef.operations.isEmpty {
                   
                    let error: WebArchiveError?
                    
                    if networkFailed {
                        error = .noNetworkConnection
                    }
                    else if cancelled {
                        error = .cancelled
                    }
                    else {
                        error = nil
                    }
                    
                    complete(error)
                }
            }
            
            operations.append(operation)
        }
        
        if operations.count > 0 {
            queue.addOperations(operations, waitUntilFinished: false)
        }
        else {
            complete(nil)
        }
        
        return queue
    }
}
