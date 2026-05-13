//
//  MobileContentAuthProviderToken.swift
//  godtools
//
//  Created by Rachael Skeath on 5/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum MobileContentAuthProviderToken: Sendable {
    
    case appleAuth(authCode: String, givenName: String?, familyName: String?, name: String?)
    case appleRefresh(refreshToken: String)
    case facebookLimitedLogin(oidcToken: String)
    case google(idToken: String)
}
