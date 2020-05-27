//
//  ArticleAemImportApi.swift
//  godtools
//
//  Created by Levi Eggert on 4/21/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleAemImportApi {
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    
    required init() {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 20
            
        session = URLSession(configuration: configuration)
    }
    
    func newAemImportOperation(godToolsResource: GodToolsResource, aemImportSrc: String, maxAemImportJsonTreeLevels: Int) -> ArticleAemImportOperation {
        
        return ArticleAemImportOperation(
            session: session,
            godToolsResource: godToolsResource,
            aemImportSrc: aemImportSrc,
            maxAemImportJsonTreeLevels: maxAemImportJsonTreeLevels
        )
    }
    
    func downloadAemImportSrcs(godToolsResource: GodToolsResource, aemImportSrcs: [String], maxAemImportJsonTreeLevels: Int, didDownloadAemImport: @escaping ((_ response: RequestResponse, _ result: Result<ArticleAemImportData, ArticleAemImportOperationError>) -> Void), complete: @escaping ((_ error: ArticleAemImportApiError?) -> Void)) -> OperationQueue {
        
        let queue = OperationQueue()
        
        var operations: [ArticleAemImportOperation] = Array()
        
        var networkFailed: Bool = false
        var operationCancelled: Bool = false
                
        for aemImportSrc in aemImportSrcs {
            
            let operation = newAemImportOperation(
                godToolsResource: godToolsResource,
                aemImportSrc: aemImportSrc,
                maxAemImportJsonTreeLevels: maxAemImportJsonTreeLevels
            )
            
            operation.completionHandler { (response: RequestResponse, result: Result<ArticleAemImportData, ArticleAemImportOperationError>) in
                
                switch result {
                case .success( _):
                    break
                case .failure(let aemImportOperationError):
                    switch aemImportOperationError {
                    case .cancelled:
                        operationCancelled = true
                    case .failedToParseJson( _):
                        break
                    case .failedToSerializeJson( _):
                        break
                    case .invalidAemImportJsonUrl:
                        break
                    case .invalidAemImportSrcUrl:
                        break
                    case .noNetworkConnection:
                        networkFailed = true
                    case .unknownError( _):
                        break
                    }
                }
                
                didDownloadAemImport(response, result)
                
                if queue.operations.isEmpty {
                    
                    let error: ArticleAemImportApiError?
                    
                    if networkFailed {
                        error = .noNetworkConnection
                    }
                    else if operationCancelled {
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
