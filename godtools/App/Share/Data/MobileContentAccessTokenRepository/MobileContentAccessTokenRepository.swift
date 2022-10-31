//
//  MobileContentAccessTokenRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 10/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MobileContentAccessTokenRepository {
    
    func getAccessToken() -> String {
        
        // TODO: - fetch from keychain, otherwise request new one
        
        return ""
    }
    
    private func storeAccessTokenInKeychain(_ accessToken: String) {
        
    }
    
    private func getAccessTokenFromKeychain() -> String? {
        return nil
    }
    
    private func requestAccessTokenFromMobileContentAPI() {
        // TODO: - stuff
        
        storeAccessTokenInKeychain("something")
    }
}
