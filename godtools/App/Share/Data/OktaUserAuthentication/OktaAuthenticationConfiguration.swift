//
//  OktaAuthenticationConfiguration.swift
//  godtools
//
//  Created by Levi Eggert on 12/2/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import OktaAuthentication

class OktaAuthenticationConfiguration {
    
    required init() {
        
    }
    
    func configureAndCreateNewOktaAuthentication(config: AppConfig) -> CruOktaAuthentication {
                
        let signInPath: String = "auth"
        let signOutPath: String = "auth/logout"
        let redirectBaseUrl: String
        
        if config.isDebug {
            redirectBaseUrl = "org.cru.godtools.debug"
        }
        else {
            redirectBaseUrl = "org.cru.godtools"
        }
        
        let logoutRedirectUri: String = "\(redirectBaseUrl):/\(signOutPath)"
        let redirectUri: String = "\(redirectBaseUrl):/\(signInPath)"
        
        return CruOktaAuthentication(
            clientId: "0oa1ju0zx08vYGgbB0h8",
            logoutRedirectUri: logoutRedirectUri,
            issuer: "https://signon.okta.com",
            redirectUri: redirectUri
        )
    }
}
