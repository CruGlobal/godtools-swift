//
//  MobileContentApiAuthSession.swift
//  godtools
//
//  Created by Rachael Skeath on 11/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class MobileContentApiAuthSession {
    
    let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession) {
     
        self.session = ignoreCacheSession.session
    }
    
    private func buildAuthenticatedRequest(for urlString: String, authToken: String) -> URLRequest {
        
        let headers: [String: String] = [
            "Authorization": authToken
        ]
        
        return requestBuilder.build(
            session: session,
            urlString: urlString,
            method: .get,
            headers: headers,
            httpBody: nil,
            queryItems: nil
        )
    }
}
