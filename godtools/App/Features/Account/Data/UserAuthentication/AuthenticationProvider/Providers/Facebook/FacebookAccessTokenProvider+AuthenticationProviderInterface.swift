//
//  FacebookAccessTokenProvider+AuthenticationProviderInterface.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SocialAuthentication
import FBSDKLoginKit

// NOTE: Requires App Tracking Transparency is enabled by the user.
// Ensure Key (Privacy - Tracking Usage Description) with value is provided in the Info.plist.

extension FacebookAccessTokenProvider: AuthenticationProviderInterface {
    
    private func getResponseForPersistedData() throws -> AuthenticationProviderResponse {
        
        guard let accessToken = getAccessToken(), let profile = LoadFacebookProfile.current else {
            
            let error: Error = NSError.errorWithDescription(description: "Data not persisted.")
            
            throw error
        }
        
        let response = AuthenticationProviderResponse(
            accessToken: accessToken.tokenString,
            appleSignInAuthorizationCode: nil,
            idToken: nil,
            oidcToken: nil,
            profile: profile.toAuthProviderProfile(),
            providerType: .facebook,
            refreshToken: nil
        )
        
        return response
    }
    
    @MainActor func providerAuthenticate(presentingViewController: UIViewController) async throws -> AuthenticationProviderResponse {
     
        let facebookResponse: FacebookAccessTokenProviderResponse = try await authenticate(from: presentingViewController)
        
        if facebookResponse.isCancelled {
            throw NSError.userCancelledError()
        }
        
        return try getResponseForPersistedData()
    }
    
    func providerRenewToken() async throws -> AuthenticationProviderResponse {
        
        _ = try await refreshCurrentAccessToken()
        
        return try getResponseForPersistedData()
    }
    
    func providerSignOut() {
        
        signOut()
    }
    
    func providerGetAuthUser() async throws -> AuthUserDomainModel? {
        
        return try await LoadFacebookProfile().getCurrentProfileElseLoad()?.toAuthUserDomainModel()
    }
}
