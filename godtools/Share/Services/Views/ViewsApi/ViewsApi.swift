//
//  ViewsApi.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ViewsApi: ViewsApiType {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseUrl: String
    
    let session: URLSession
    
    required init(config: ConfigType) {
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        configuration.urlCache = nil
        
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        
        configuration.timeoutIntervalForRequest = 30
            
        session = URLSession(configuration: configuration)
        
        baseUrl = config.mobileContentApiBaseUrl
    }
    
    private func newAddViewsRequest(resourceId: Int, quantity: Int) -> URLRequest {
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        let body: [String: Any] = [
            "data": [
                "type": "view",
                "attributes": [
                    "resource_id": resourceId,
                    "quantity": quantity
                ]
            ]
        ]
        
        return requestBuilder.build(
            session: session,
            urlString: baseUrl + "/views",
            method: .post,
            headers: headers,
            httpBody: body
        )
    }
    
    func newAddViewsOperation(resourceId: Int, quantity: Int) -> RequestOperation {
        
        let urlRequest = newAddViewsRequest(resourceId: resourceId, quantity: quantity)
        let operation = RequestOperation(
            session: session,
            urlRequest: urlRequest
        )
        
        return operation
    }
    
    func addViews(resourceId: Int, quantity: Int, complete: @escaping ((_ result: Result<Data?, ResponseError<NoClientApiErrorType>>) -> Void)) -> OperationQueue {
        
        let addViewsOperation = newAddViewsOperation(resourceId: resourceId, quantity: quantity)
        
        return SingleRequestOperation().execute(operation: addViewsOperation, completeOnMainThread: true) { (response: RequestResponse, result: ResponseResult<NoResponseSuccessType, NoClientApiErrorType>) in
                        
            switch result {
            case .success( _, _):
                complete(.success(response.data))
            case .failure(let error):
                complete(.failure(error))
            }
        }
    }
}
