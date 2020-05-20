//
//  GlobalActivityAnalyticsApi.swift
//  godtools
//
//  Created by Levi Eggert on 2/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class GlobalActivityAnalyticsApi: GlobalActivityAnalyticsApiType {
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseUrl: String
    
    init(config: ConfigType) {
        
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
        
    private var globalAnalyticsOperation: RequestOperation {
        
        let urlRequest: URLRequest = requestBuilder.build(
            session: session,
            urlString: baseUrl + "/analytics/global",
            method: .get,
            headers: nil,
            httpBody: nil
        )
        
        return RequestOperation(session: session, urlRequest: urlRequest)
    }

    func getGlobalAnalytics(complete: @escaping ((_ response: RequestResponse, _ result: RequestResult<GlobalActivityAnalytics, RequestClientError>) -> Void)) -> OperationQueue {
        
        return globalAnalyticsOperation.executeRequest { (response: RequestResponse) in
                        
            let result: RequestResult<GlobalActivityAnalytics, RequestClientError> = response.getResult()
            
            DispatchQueue.main.async {
                
                complete(response, result)
            }
        }
    }
}
