//
//  AuthenticationProviderAccessToken.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum AuthenticationProviderAccessToken {
    
    case apple(idToken: String, givenName: String, familyName: String)
    case facebook(accessToken: String)
    case google(idToken: String)
}

extension AuthenticationProviderAccessToken {
    
    var tokenString: String {
        
        switch self {
            
        case .apple(let idToken, _, _):
            return idToken
            
        case .facebook(let accessToken):
            return accessToken
            
        case .google(let idToken):
            return idToken
        }
    }
}
