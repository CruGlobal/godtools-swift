//
//  MobileContentAccessTokenAPI.swift
//  godtools
//
//  Created by Rachael Skeath on 10/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RequestOperation

class MobileContentAccessTokenAPI {
    
    private let session: URLSession
    private let requestBuilder: RequestBuilder = RequestBuilder()
    private let baseURL: String
    
    init(config: AppConfig, ignoreCacheSession: IgnoreCacheSession) {
        
        self.session = ignoreCacheSession.session
        self.baseURL = config.mobileContentApiBaseUrl
    }
    
    func getAccessToken(okta)
}
