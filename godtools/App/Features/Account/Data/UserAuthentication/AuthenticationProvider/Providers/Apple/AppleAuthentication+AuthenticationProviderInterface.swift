//
//  AppleAuthentication+AuthenticationProviderInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 5/16/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit
import SocialAuthentication
import Combine

extension AppleAuthentication: AuthenticationProviderInterface {
    
    private func getAuthenticationProviderResponse(appleAuthResponse: AppleAuthenticationResponse) throws -> AuthenticationProviderResponse {
        
        guard let authCode = appleAuthResponse.authorizationCode else {
            throw NSError.errorWithDescription(description: "Failed to get authorization code.")
        }
        
        let name: String? = appleAuthResponse.fullName?.formatted()
        
        let response = AuthenticationProviderResponse(
            accessToken: nil,
            appleSignInAuthorizationCode: authCode,
            idToken: appleAuthResponse.identityToken,
            oidcToken: nil,
            profile: AuthenticationProviderProfile(
                email: appleAuthResponse.email,
                familyName: appleAuthResponse.fullName?.familyName,
                givenName: appleAuthResponse.fullName?.givenName,
                name: name
            ),
            providerType: .apple,
            refreshToken: nil
        )
        
        return response
    }
    
    @MainActor func providerAuthenticate(presentingViewController: UIViewController) async throws -> AuthenticationProviderResponse {
        
        let appleAuthResponse: AppleAuthenticationResponse = try await authenticate()
        
        if appleAuthResponse.isCancelled {
            throw NSError.userCancelledError()
        }
        
        return try getAuthenticationProviderResponse(appleAuthResponse: appleAuthResponse)
    }
    
    func providerRenewToken() async throws -> AuthenticationProviderResponse {
        
        // Apple token renewal is handled in UserAuthentication since Apple token renewal occurs through Mobile-Content-Api.
        let error: Error = NSError.errorWithDescription(description: "Access token renewal is handled in UserAuthentication.swift-- this method shouldn't be called.")

        throw error
    }
    
    func providerSignOut() {
        
        _ = signOut()
    }
    
    func providerGetAuthUser() async throws -> AuthUserDomainModel? {
        
        let appleUserProfile: AppleUserProfile = getCurrentUserProfile()
        
        return appleUserProfile.toAuthUserDomainModel()
    }
}
