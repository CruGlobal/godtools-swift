//
//  ResourcesApi.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ResourcesApi: ResourcesApiType {
    
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
    
    func newResourcesPlusLatestTranslationsAndAttachmentsOperation() -> RequestOperation {
        
        let urlRequest: URLRequest = requestBuilder.build(
            session: session,
            urlString: baseUrl + "/resources?include=latest-translations,attachments",
            method: .get,
            headers: nil,
            httpBody: nil
        )
        
        return RequestOperation(session: session, urlRequest: urlRequest)
    }
    
    func getResourcesPlusLatestTranslationsAndAttachments(complete: @escaping ((_ result: Result<Data?, ResponseError<NoClientApiErrorType>>) -> Void)) -> OperationQueue {
        
        let resourcesOperation: RequestOperation = newResourcesPlusLatestTranslationsAndAttachmentsOperation()
        
        return SingleRequestOperation().execute(operation: resourcesOperation, completeOnMainThread: false) { (response: RequestResponse, result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType>) in
            
            switch result {
            case .success( _, _):
                complete(.success(response.data))
            case .failure(let error):
                complete(.failure(error))
            }
        }
    }
}
