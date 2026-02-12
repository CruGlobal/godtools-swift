//
//  GoogleAuthentication+AuthenticationProviderInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit
import SocialAuthentication
import Combine
import GoogleSignIn

extension GoogleAuthentication: AuthenticationProviderInterface {
    
    private func getResponseForPersistedData() throws -> AuthenticationProviderResponse {
        
        guard let user = getCurrentUser(), let idToken = user.idToken?.tokenString else {
            
            let error: Error = NSError.errorWithDescription(description: "Data not persisted.")
            
            throw error
        }
        
        let response = AuthenticationProviderResponse(
            accessToken: user.accessToken.tokenString,
            appleSignInAuthorizationCode: nil,
            idToken: idToken,
            oidcToken: nil,
            profile: AuthenticationProviderProfile(
                email: user.profile?.email,
                familyName: user.profile?.familyName,
                givenName: user.profile?.givenName,
                name: user.profile?.name
            ),
            providerType: .google,
            refreshToken: user.refreshToken.tokenString
        )
        
        return response
    }
    
    @MainActor func providerAuthenticate(presentingViewController: UIViewController) async throws -> AuthenticationProviderResponse {
        
        let googleResponse: GoogleAuthenticationResponse = try await authenticate(from: presentingViewController)
        
        if googleResponse.isCancelled {
            throw NSError.userCancelledError()
        }
        
        return try getResponseForPersistedData()
    }

    func providerRenewToken() async throws -> AuthenticationProviderResponse {
        
        _ = try await restorePreviousSignIn()
        
        return try getResponseForPersistedData()
    }
    
    func providerSignOut() {
        
        signOut()
    }
    
    func providerGetAuthUser() async throws -> AuthUserDomainModel? {
        
        let profile: GIDProfileData? = getCurrentUserProfile()
        
        return profile?.toAuthUserDomainModel()
    }
}
