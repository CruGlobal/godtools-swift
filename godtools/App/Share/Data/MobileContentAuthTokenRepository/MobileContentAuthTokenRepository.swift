//
//  MobileContentAuthTokenRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 10/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MobileContentAuthTokenRepository {
    
    func getAuthToken() -> String {
        
        // TODO: - fetch from keychain, otherwise request new one
        
        return ""
    }
    
    private func storeAuthTokenInKeychain(_ accessToken: String) {
        
    }
    
    private func getAuthTokenFromKeychain() -> String? {
        return nil
    }
    
    private func requestAuthTokenFromMobileContentAPI() {
        // TODO: - stuff
        
        storeAuthTokenInKeychain("something")
    }
}
