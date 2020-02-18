//
//  RequestBuilder.swift
//  godtools
//
//  Created by Levi Eggert on 2/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class RequestBuilder {
    
    required init() {
        
    }
    
    func buildRequest(session: URLSession, urlString: String, method: RequestMethod, headers: [String: String]?, httpBody: [String: Any]?) -> URLRequest {
        
        let url: URL? = URL(string: urlString)
        
        if let url = url {
            let result: Result<URLRequest, Error> = buildRequest(session: session, url: url, method: method, headers: headers, httpBody: httpBody)
            switch result {
            case .success(let request):
                return request
            case .failure(let error):
                assertionFailure(error.localizedDescription)
                return URLRequest(url: url)
            }
        }
        else {
            let errorDescription: String = "Failed to build url with string: \(urlString)"
            assertionFailure(errorDescription)
            return URLRequest(url: url!)
        }
    }
    
    func buildRequest(session: URLSession, url: URL, method: RequestMethod, headers: [String: String]?, httpBody: [String: Any]?) -> Result<URLRequest, Error> {
        
        let configuration = session.configuration
        
        var urlRequest = URLRequest(
            url: url,
            cachePolicy: configuration.requestCachePolicy,
            timeoutInterval: configuration.timeoutIntervalForRequest
        )
        
        if let headers = headers {
            for (key, value) in headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        urlRequest.httpMethod = method.rawValue
        
        if let httpBody = httpBody {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: httpBody, options: [])
            }
            catch let error {
                return .failure(error)
            }
        }
    
        return .success(urlRequest)
    }
}
