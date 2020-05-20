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
    
    func downloadAemImportSrcs(godToolsResource: GodToolsResource, aemImportSrcs: [String], maxAemImportJsonTreeLevels: Int, didDownloadAemImport: @escaping ((_ response: RequestResponse, _ result: Result<ArticleAemImportData, Error>) -> Void), complete: @escaping ((_ error: Error?) -> Void)) -> OperationQueue {
        
        let queue = OperationQueue()
        
        var operations: [ArticleAemImportOperation] = Array()
        var didCompleteWithError: Bool = false
                
        for aemImportSrc in aemImportSrcs {
            
            let operation = newAemImportOperation(
                godToolsResource: godToolsResource,
                aemImportSrc: aemImportSrc,
                maxAemImportJsonTreeLevels: maxAemImportJsonTreeLevels
            )
            
            operation.completionHandler { (response: RequestResponse, result: Result<ArticleAemImportData, Error>) in
            
                guard !didCompleteWithError else {
                    return
                }
                
                if let error = response.error, response.notConnectedToInternet {
                    
                    didCompleteWithError = true
                    
                    queue.cancelAllOperations()
                    
                    complete(error)
                    
                    return
                }
                
                didDownloadAemImport(response, result)
                
                if queue.operations.isEmpty {
                    
                    complete(nil)
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
