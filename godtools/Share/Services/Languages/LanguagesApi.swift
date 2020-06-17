//
//  LanguagesApi.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LanguagesApi: LanguagesApiType {
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseUrl: String
    
    required init(config: ConfigType) {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 60
            
        session = URLSession(configuration: configuration)
        
        baseUrl = config.mobileContentApiBaseUrl
    }
    
    func newGetLanguagesOperation() -> RequestOperation {
        
        let urlRequest: URLRequest = requestBuilder.build(
            session: session,
            urlString: baseUrl + "/languages",
            method: .get,
            headers: nil,
            httpBody: nil
        )
        
        return RequestOperation(session: session, urlRequest: urlRequest)
    }
    
    func getLanguages(complete: @escaping ((_ result: Result<Data?, Error>) -> Void)) -> OperationQueue {
        
        let queue = OperationQueue()
        
        let languagesOperation: RequestOperation = newGetLanguagesOperation()
                    
        languagesOperation.completionHandler { (response: RequestResponse) in
            
            let result: RequestResult<NoRequestResultType, NoRequestResultType> = response.getResult()
            
            switch result {
            case .success( _):
                complete(.success(response.data))
            case .failure( _, let error):
                complete(.failure(error))
            }
        }
        
        queue.addOperations([languagesOperation], waitUntilFinished: false)
        
        return queue
    }
}
