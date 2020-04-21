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
    
    func createNewAemImportRequest(url: URL) -> URLRequest? {
        
        let result =  requestBuilder.build(
            session: session,
            url: url,
            method: .get,
            headers: nil,
            httpBody: nil
        )
        
        switch result {
        case .success(let request):
            return request
        case .failure(let error):
            return nil
        }
    }
    
    func createNewAemImportOperation(url: URL) -> RequestOperation<NoRequestResultType, NoRequestResultType>? {
        
        if let urlRequest = createNewAemImportRequest(url: url) {
            
            return RequestOperation(
                session: session,
                urlRequest: urlRequest
            )
        }
        
        return nil
    }
    
    func getAllAemImports(urls: [URL], complete: (() -> Void)) {
        
        var operations: [RequestOperation<NoRequestResultType, NoRequestResultType>] = Array()
        
        for url in urls {
            
            if let operation = createNewAemImportOperation(url: url) {
                
                operation.completionHandler { (response: RequestResponse, result: RequestResult<NoRequestResultType, NoRequestResultType>) in
                    
                    print("\n FINISHED AEM IMPORT")
                    response.log()
                }
                
                operations.append(operation)
            }
        }
        
        let operationQueue = OperationQueue()
        operationQueue.addOperations(operations, waitUntilFinished: false)
    }
}
