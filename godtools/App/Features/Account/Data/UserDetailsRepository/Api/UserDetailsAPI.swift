//
//  UserDetailsAPI.swift
//  godtools
//
//  Created by Rachael Skeath on 11/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class UserDetailsAPI: UserDetailsAPIInterface {
    
    private let authSession: MobileContentApiAuthSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let urlSessionPriority: URLSessionPriority
    private let baseURL: String
    
    init(config: AppConfigInterface, urlSessionPriority: URLSessionPriority, mobileContentApiAuthSession: MobileContentApiAuthSession) {
        
        self.urlSessionPriority = urlSessionPriority
        self.authSession = mobileContentApiAuthSession
        self.baseURL = config.getMobileContentApiBaseUrl()
    }
    
    func fetchUserDetailsPublisher(requestPriority: RequestPriority) -> AnyPublisher<MobileContentApiUsersMeCodable, Error> {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getAuthUserDetailsRequest(urlSession: urlSession)
                
        return authSession.sendAuthenticatedRequest(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
        .decode(type: JsonApiResponseDataObject<MobileContentApiUsersMeCodable>.self, decoder: JSONDecoder())
        .map {
            return $0.dataObject
        }
        .eraseToAnyPublisher()
    }
    
    private func getAuthUserDetailsRequest(urlSession: URLSession) -> URLRequest {
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseURL + "/users/me",
                method: .get,
                headers: headers,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
    
    func deleteAuthUserDetailsPublisher(requestPriority: RequestPriority) -> AnyPublisher<Void, Error> {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest = getDeleteAuthorizedUserDetailsRequest(urlSession: urlSession)
                
        return authSession.sendAuthenticatedRequest(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
        .map { (data: Data) in
            
            return ()
        }
        .eraseToAnyPublisher()
    }
    
    private func getDeleteAuthorizedUserDetailsRequest(urlSession: URLSession) -> URLRequest {
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: urlSession,
                urlString: baseURL + "/users/me",
                method: .delete,
                headers: headers,
                httpBody: nil,
                queryItems: nil
            )
        )
    }
}
