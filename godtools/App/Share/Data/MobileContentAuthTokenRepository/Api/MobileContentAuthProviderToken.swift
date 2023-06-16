//
//  MobileContentAuthProviderToken.swift
//  godtools
//
//  Created by Rachael Skeath on 5/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum MobileContentAuthProviderToken {
    
    case appleAuth(authCode: String, givenName: String?, familyName: String?)
    case appleRefresh(refreshToken: String)
    case facebook(accessToken: String)
    case google(idToken: String)
}
