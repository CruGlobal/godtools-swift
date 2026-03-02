//
//  AuthenticationProviderProfile.swift
//  godtools
//
//  Created by Levi Eggert on 6/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct AuthenticationProviderProfile: Sendable {
    
    let email: String?
    let familyName: String?
    let givenName: String?
    let name: String?
    
    static var emptyProfile: AuthenticationProviderProfile {
        return AuthenticationProviderProfile(email: nil, familyName: nil, givenName: nil, name: nil)
    }
}
