//
//  AuthenticationProviderResponse+MobileContentAuthProviderToken.swift
//  godtools
//
//  Created by Levi Eggert on 6/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension AuthenticationProviderResponse {
    
    func getMobileContentAuthProviderToken() -> MobileContentAuthProviderToken {
        
        return getMobileContentAuthProviderToken(providerType: providerType)
    }
    
    private func getMobileContentAuthProviderToken(providerType: AuthenticationProviderType) -> MobileContentAuthProviderToken {
        
        switch providerType {
            
        case .apple:
            return .apple(idToken: idToken, givenName: profile.givenName, familyName: profile.familyName)
            
        case .facebook:
            return .facebook(accessToken: accessToken)
            
        case .google:
            return .google(idToken: idToken)
        }
    }
}
