//
//  AuthenticationProviderResponse+MobileContentAuthProviderToken.swift
//  godtools
//
//  Created by Levi Eggert on 6/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension AuthenticationProviderResponse {
    
    func getMobileContentAuthProviderToken() -> Result<MobileContentAuthProviderToken, Error> {
        
        return getMobileContentAuthProviderToken(providerType: providerType)
    }
    
    private func getMobileContentAuthProviderToken(providerType: AuthenticationProviderType) -> Result<MobileContentAuthProviderToken, Error> {
        
        switch providerType {
            
        case .apple:
            
            guard let idToken = self.idToken, !idToken.isEmpty else {
                return .failure(NSError.errorWithDescription(description: "Missing apple idToken."))
            }
            
            return .success(.apple(idToken: idToken, givenName: profile.givenName, familyName: profile.familyName))
                        
        case .facebook:
            
            guard let accessToken = self.accessToken, !accessToken.isEmpty else {
                return .failure(NSError.errorWithDescription(description: "Missing facebook accesstoken."))
            }
            
            return .success(.facebook(accessToken: accessToken))
            
        case .google:
            
            guard let idToken = self.idToken, !idToken.isEmpty else {
                return .failure(NSError.errorWithDescription(description: "Missing google idToken."))
            }
            
            return .success(.google(idToken: idToken))
        }
    }
}
