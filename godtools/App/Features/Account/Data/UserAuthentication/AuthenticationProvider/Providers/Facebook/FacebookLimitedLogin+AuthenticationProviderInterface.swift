//
//  FacebookLimitedLogin+AuthenticationProviderInterface.swift
//  godtools
//
//  Created by Levi Eggert on 6/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SocialAuthentication
import FBSDKLoginKit

extension FacebookLimitedLogin: AuthenticationProviderInterface {
    
    @MainActor func providerAuthenticate(presentingViewController: UIViewController) async throws -> AuthenticationProviderResponse {
        
        let facebookResponse: FacebookLimitedLoginResponse = try await authenticate(from: presentingViewController)
        
        let profile: FacebookProfile? = try await LoadFacebookProfile().getCurrentProfileElseLoad()
        
        let providerProfile: AuthenticationProviderProfile = profile?.toAuthProviderProfile() ?? AuthenticationProviderProfile.emptyProfile
        
        return AuthenticationProviderResponse(
            accessToken: nil,
            appleSignInAuthorizationCode: nil,
            idToken: nil,
            oidcToken: facebookResponse.oidcToken,
            profile: providerProfile,
            providerType: .facebook,
            refreshToken: nil
        )
    }
    
    func providerRenewToken() async throws -> AuthenticationProviderResponse {
     
        let profile: FacebookProfile? = try await LoadFacebookProfile().getCurrentProfileElseLoad()
        
        let providerProfile: AuthenticationProviderProfile = profile?.toAuthProviderProfile() ?? AuthenticationProviderProfile.emptyProfile
        
        let oidcToken: String? = getAuthenticationTokenString()
        
        let response = AuthenticationProviderResponse(
            accessToken: nil,
            appleSignInAuthorizationCode: nil,
            idToken: nil,
            oidcToken: oidcToken,
            profile: providerProfile,
            providerType: .facebook,
            refreshToken: nil
        )
        
        return response
    }
    
    func providerSignOut() {
        
        signOut()
    }
    
    func providerGetAuthUser() async throws -> AuthUserDomainModel? {
        
        return try await LoadFacebookProfile().getCurrentProfileElseLoad()?.toAuthUserDomainModel()
    }
}
