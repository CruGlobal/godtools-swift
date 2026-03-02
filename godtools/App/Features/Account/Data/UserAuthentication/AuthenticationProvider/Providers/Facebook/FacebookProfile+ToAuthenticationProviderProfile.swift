//
//  FacebookProfile+ToAuthenticationProviderProfile.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SocialAuthentication

extension FacebookProfile {
    
    func toAuthProviderProfile() -> AuthenticationProviderProfile {
        
        return AuthenticationProviderProfile(
            email: email,
            familyName: lastName,
            givenName: firstName,
            name: name
        )
    }
}
