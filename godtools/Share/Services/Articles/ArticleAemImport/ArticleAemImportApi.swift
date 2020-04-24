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
        
        configuration.timeoutIntervalForRequest = 60
            
        session = URLSession(configuration: configuration)
    }
    
    func createNewAemImportOperation(aemImportSrc: String, maxAemImportJsonTreeLevels: Int) -> ArticleAemImportOperation {
        
        return ArticleAemImportOperation(
            session: session,
            aemImportSrc: aemImportSrc,
            maxAemImportJsonTreeLevels: maxAemImportJsonTreeLevels
        )
    }
    
    func downloadAemImportSrcs(aemImportSrcs: [String], maxAemImportJsonTreeLevels: Int, didDownloadAemImport: @escaping ((_ response: RequestResponse, _ result: Result<ArticleAemImportData, Error>) -> Void), complete: (() -> Void)? = nil) -> OperationQueue {
        
        let operationQueue = OperationQueue()
        
        var operations: [ArticleAemImportOperation] = Array()
        
        for aemImportSrc in aemImportSrcs {
            
            let operation = createNewAemImportOperation(aemImportSrc: aemImportSrc, maxAemImportJsonTreeLevels: maxAemImportJsonTreeLevels)
            
            operation.completionHandler { (response: RequestResponse, result: Result<ArticleAemImportData, Error>) in
                
                didDownloadAemImport(response, result)
                
                let finished: Bool = operationQueue.operations.isEmpty
                
                if finished, let complete = complete {
                    complete()
                }
            }
            
            operations.append(operation)
        }
        
        if operations.count > 0 {
            operationQueue.addOperations(operations, waitUntilFinished: false)
        }
        else if let complete = complete {
            complete()
        }
        
        return operationQueue
    }
}
