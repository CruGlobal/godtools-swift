//
//  AuthenticationProviderTokenResponse.swift
//  godtools
//
//  Created by Levi Eggert on 6/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct AuthenticationProviderTokenResponse {
 
    let accessToken: String?
    let expires: Date?
    let idToken: String
    let refreshToken: String?
    let tokenType: String?
}
