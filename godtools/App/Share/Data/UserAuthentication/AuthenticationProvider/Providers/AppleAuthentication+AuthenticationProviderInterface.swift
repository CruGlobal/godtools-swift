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
    
    private func getAuthenticationProviderResponse(appleAuthResponse: AppleAuthenticationResponse) -> AuthenticationProviderResponse {
        
        return AuthenticationProviderResponse(
            accessToken: "",
            idToken: appleAuthResponse.identityToken ?? "",
            profile: AuthenticationProviderProfile(
                email: appleAuthResponse.email,
                familyName: appleAuthResponse.fullName?.familyName,
                givenName: appleAuthResponse.fullName?.givenName
            ),
            providerType: .apple,
            refreshToken: ""
        )
    }
    
    func getPersistedResponse() -> AuthenticationProviderResponse? {
        
        // TODO: - access token renewal will come through MobileContentAPI?
        
        return nil
    }
    
    func authenticatePublisher(presentingViewController: UIViewController) -> AnyPublisher<AuthenticationProviderResponse, Error> {
        
        return authenticatePublisher()
            .map { (response: AppleAuthenticationResponse) in
                
                return self.getAuthenticationProviderResponse(appleAuthResponse: response)
            }
            .eraseToAnyPublisher()
    }
    
    func renewAccessTokenPublisher() -> AnyPublisher<AuthenticationProviderResponse, Error> {
        
        // TODO: - implement in GT-2042
        
        let error: Error = NSError.errorWithDescription(description: "Access token renewal not yet implemented")

        return Fail(error: error)
            .eraseToAnyPublisher()
    }
    
    func signOutPublisher() -> AnyPublisher<Void, Error> {
        
        signOut()
        
        return Just(()).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getAuthUserPublisher() -> AnyPublisher<AuthUserDomainModel?, Error> {
                
        let profile = getCurrentUserProfile()
        
        return Just(mapProfileToAuthUser(profile: profile))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func mapProfileToAuthUser(profile: AppleUserProfile) -> AuthUserDomainModel {
        
        return AuthUserDomainModel(
            email: profile.email ?? "",
            firstName: profile.givenName,
            grMasterPersonId: nil,
            lastName: profile.familyName,
            ssoGuid: nil
        )
    }
}
