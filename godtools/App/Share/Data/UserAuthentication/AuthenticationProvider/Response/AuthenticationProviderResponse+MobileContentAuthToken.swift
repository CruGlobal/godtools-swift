//
//  AuthenticationProviderResponse+MobileContentAuthToken.swift
//  godtools
//
//  Created by Levi Eggert on 6/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension AuthenticationProviderResponse {
    
    func getMobileContentAuthToken() -> MobileContentAuthToken {
        
        return getMobileContentAuthToken(providerType: providerType)
    }
    
    private func getMobileContentAuthToken(providerType: AuthenticationProviderType) -> MobileContentAuthToken {
        
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
