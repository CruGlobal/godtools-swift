//
//  MobileContentAuthTokenRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 10/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import OktaAuthentication
import Combine

class MobileContentAuthTokenRepository {
    
    private let api: MobileContentAuthTokenAPI
    
    init(api: MobileContentAuthTokenAPI) {
        
        self.api = api
    }
    
    func getAuthToken() -> String {
        
        // TODO: - fetch from keychain, otherwise request new one
        
        return ""
    }
    
    private func storeAuthTokenInKeychain(_ accessToken: String) {
        
    }
    
    private func getAuthTokenFromKeychain() -> String? {
        return nil
    }
    
    
    func requestAuthTokenPublisher(_ accessToken: OktaAccessToken) -> AnyPublisher<MobileContentAuthTokenDataModel, URLResponseError> {
        
        return api.getAuthToken(oktaAccessToken: accessToken)
    }
}
