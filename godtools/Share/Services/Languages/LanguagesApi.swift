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
    
    func getLanguages(complete: @escaping ((_ result: Result<Data?, ResponseError<NoClientApiErrorType>>) -> Void)) -> OperationQueue {
        
        let languagesOperation: RequestOperation = newGetLanguagesOperation()
        
        return SingleRequestOperation().execute(operation: languagesOperation, completeOnMainThread: false) { (response: RequestResponse, result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType>) in
            
            switch result {
            case .success( _, _):
                complete(.success(response.data))
            case .failure(let error):
                complete(.failure(error))
            }
        }
    }
}
