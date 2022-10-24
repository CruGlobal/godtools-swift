//
//  CruOktaAuthentication+GetAuthenticationInstance.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import OktaAuthentication

extension CruOktaAuthentication {
    
    static func getNewAuthenticationInstance(appBuild: AppBuild) -> CruOktaAuthentication {
        
        let signInPath: String = "auth"
        let signOutPath: String = "auth/logout"
        let redirectBaseUrl: String
        
        // TODO: Change back redirectBaseUrl. ~Levi
        /*
        if appBuild.isDebug {
            redirectBaseUrl = "org.cru.godtools.debug"
        }
        else {
            redirectBaseUrl = "org.cru.godtools"
        }*/
        
        redirectBaseUrl = "org.cru.godtools"
        
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
