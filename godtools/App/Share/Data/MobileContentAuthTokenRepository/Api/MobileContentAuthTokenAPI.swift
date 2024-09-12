//
//  MobileContentAuthTokenAPI.swift
//  godtools
//
//  Created by Rachael Skeath on 10/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation
import Combine

class MobileContentAuthTokenAPI {
    
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let requestSender: RequestSender
    private let baseURL: String
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession) {
        
        requestSender = RequestSender(session: ignoreCacheSession.session)
        baseURL = config.getMobileContentApiBaseUrl()
    }
    
    private func getAuthTokenRequest(providerToken: MobileContentAuthProviderToken, createUser: Bool) -> URLRequest {
        
        var attributes: [String: Any] = Dictionary()
        
        attributes["create_user"] = createUser
        
        switch providerToken {
        case .appleAuth(let authCode, let givenName, let familyName, let name):
            
            attributes["apple_auth_code"] = authCode
            attributes["apple_given_name"] = givenName
            attributes["apple_family_name"] = familyName
            
            if let name = name {
                attributes["apple_name"] = name
            }
            
        case .appleRefresh(let refreshToken):
            
            attributes["apple_refresh_token"] = refreshToken
            attributes["create_user"] = nil // Will not provide create_user flag on apple refresh.
                        
        case .facebook(let accessToken):
            
            attributes["facebook_access_token"] = accessToken
            
        case .google(let idToken):
            
            attributes["google_id_token"] = idToken
        }
        
        let body: [String: Any] = [
            "data": [
                "type": "auth-token-request",
                "attributes": attributes
            ]
        ]
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        return requestBuilder.build(
            parameters: RequestBuilderParameters(
                urlSession: requestSender.session,
                urlString: baseURL + "/auth",
                method: .post,
                headers: headers,
                httpBody: body,
                queryItems: nil
            )
        )
    }
    
    func fetchAuthTokenPublisher(providerToken: MobileContentAuthProviderToken, createUser: Bool) -> AnyPublisher<MobileContentAuthTokenDecodable, MobileContentApiError> {
        
        let urlRequest: URLRequest = getAuthTokenRequest(providerToken: providerToken, createUser: createUser)
        
        return requestSender.sendDataTaskPublisher(urlRequest: urlRequest)
            .decodeRequestDataResponseForSuccessOrFailureCodable()
            .mapError { (error: Error) in
                return MobileContentApiError.other(error: error)
            }
            .flatMap { (response: RequestCodableResponse<JsonApiResponseDataObject<MobileContentAuthTokenDecodable>, MobileContentApiErrorsCodable>) -> AnyPublisher<MobileContentAuthTokenDecodable, MobileContentApiError> in
                                
                if let mobileContentApiErrors = response.failureCodable {
                    return Fail(error: MobileContentApiError.responseError(responseErrors: mobileContentApiErrors.errors))
                        .eraseToAnyPublisher()
                }
                
                if let authTokenDecodable = response.successCodable?.data {
                    return Just(authTokenDecodable)
                        .setFailureType(to: MobileContentApiError.self)
                        .eraseToAnyPublisher()
                }
                
                return Fail(error: MobileContentApiError.other(error: NSError.errorWithDescription(description: "Unable to fetch mobile content api auth token. Unknown reason.")))
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
