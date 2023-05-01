//
//  MobileContentApiUrlRequestHeaders.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class MobileContentApiUrlRequestHeaders {
    
    private static let defaultContentType: String = "application/vnd.api+json"
    
    let value: [String: String]
    
    init(authToken: MobileContentApiAuthToken? = nil, contentType: String = MobileContentApiUrlRequestHeaders.defaultContentType) {
        
        var headers: [String: String] = Dictionary()
        
        headers["Content-Type"] = contentType
        
        if let authToken = authToken {
            headers["Authorization"] = authToken.value
        }
        
        self.value = headers
    }
    
    static func authorizedHeaders(authToken: MobileContentApiAuthToken) -> MobileContentApiUrlRequestHeaders {
        return MobileContentApiUrlRequestHeaders(authToken: authToken)
    }
    
    static func defaultHeaders() -> MobileContentApiUrlRequestHeaders {
        return MobileContentApiUrlRequestHeaders()
    }
}
