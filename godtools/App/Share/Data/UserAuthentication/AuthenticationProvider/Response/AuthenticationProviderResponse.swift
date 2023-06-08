//
//  AuthenticationProviderResponse.swift
//  godtools
//
//  Created by Levi Eggert on 6/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct AuthenticationProviderResponse {
 
    let accessToken: String?
    let appleSignInAuthorizationCode: String?
    let idToken: String?
    let profile: AuthenticationProviderProfile
    let providerType: AuthenticationProviderType
    let refreshToken: String?
}
