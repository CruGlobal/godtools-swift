//
//  MobileContentAuthTokenAPI.swift
//  godtools
//
//  Created by Rachael Skeath on 10/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class MobileContentAuthTokenAPI {
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseURL: String
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession) {
        
        self.session = ignoreCacheSession.session
        self.baseURL = config.mobileContentApiBaseUrl
    }
    
    func getAuthTokenRequest(oktaAccessToken: String) -> URLRequest {
        
        let headers: [String: String] = [
            "Content-Type": "application/vnd.api+json"
        ]
        
        let body: [String: Any] = [
            "data": [
                "type": "auth-token-request",
                "attributes": [
                    "okta_access_token": oktaAccessToken
                ]
            ]
        ]
        
        return requestBuilder.build(
            session: session,
            urlString: baseURL + "/auth",
            method: .post,
            headers: headers,
            httpBody: body,
            queryItems: nil
        )
    }
}
