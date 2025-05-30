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

class UserDetailsAPI {
    
    private let authSession: MobileContentApiAuthSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let urlSessionPriority: GetUrlSessionPriorityInterface
    private let baseURL: String
    
    init(config: AppConfig, urlSessionPriority: GetUrlSessionPriorityInterface, mobileContentApiAuthSession: MobileContentApiAuthSession) {
        
        self.urlSessionPriority = urlSessionPriority
        self.authSession = mobileContentApiAuthSession
        self.baseURL = config.getMobileContentApiBaseUrl()
    }
    
    func fetchUserDetailsPublisher(sendRequestPriority: SendRequestPriority) -> AnyPublisher<MobileContentApiUsersMeCodable, Error> {
        
        let urlSession: URLSession = urlSessionPriority.getUrlSession(priority: sendRequestPriority)
        
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
    
    func deleteAuthUserDetailsPublisher(sendRequestPriority: SendRequestPriority) -> AnyPublisher<Void, Error> {
        
        let urlSession: URLSession = urlSessionPriority.getUrlSession(priority: sendRequestPriority)
        
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
