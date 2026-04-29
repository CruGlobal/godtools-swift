//
//  UserDetailsApi.swift
//  godtools
//
//  Created by Rachael Skeath on 11/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import RepositorySync

final class UserDetailsApi {
    
    private let authSession: MobileContentApiAuthSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let urlSessionPriority: URLSessionPriority
    private let baseURL: String
    
    init(config: AppConfigInterface, urlSessionPriority: URLSessionPriority, mobileContentApiAuthSession: MobileContentApiAuthSession) {
        
        self.urlSessionPriority = urlSessionPriority
        self.authSession = mobileContentApiAuthSession
        self.baseURL = config.getMobileContentApiBaseUrl()
    }
    
    func fetchUserDetails(requestPriority: RequestPriority) async throws -> MobileContentApiUsersMeCodable {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest: URLRequest = getAuthUserDetailsRequest(urlSession: urlSession)
                
        let responseData: Data = try await authSession.sendAuthenticatedRequest(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
        
        let codable: JsonApiResponseDataObject<MobileContentApiUsersMeCodable> = try JSONDecoder().decode(
            JsonApiResponseDataObject<MobileContentApiUsersMeCodable>.self,
            from: responseData
        )
        
        return codable.dataObject
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
    
    func deleteAuthUserDetails(requestPriority: RequestPriority) async throws {
        
        let urlSession: URLSession = urlSessionPriority.getURLSession(priority: requestPriority)
        
        let urlRequest = getDeleteAuthorizedUserDetailsRequest(urlSession: urlSession)
        
        _ = try await authSession.sendAuthenticatedRequest(
            urlRequest: urlRequest,
            urlSession: urlSession
        )
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
