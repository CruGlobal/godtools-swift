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
    
    func authenticatePublisher(presentingViewController: UIViewController) -> AnyPublisher<AuthenticationProviderResponse, Error> {
        
        return authenticatePublisher(from: presentingViewController)
            .map { (response: FacebookLimitedLoginResponse) in
                   
                let profile = AuthenticationProviderProfile(
                    email: nil,
                    familyName: nil,
                    givenName: nil,
                    name: nil
                )
                
                return AuthenticationProviderResponse(
                    accessToken: nil,
                    appleSignInAuthorizationCode: nil,
                    idToken: nil,
                    oidcToken: response.oidcToken,
                    profile: profile,
                    providerType: .facebook,
                    refreshToken: nil
                )
            }
            .eraseToAnyPublisher()
    }
    
    func renewTokenPublisher() -> AnyPublisher<AuthenticationProviderResponse, Error> {
        
        // TODO: GT-2392 Implement. ~Levi
        // TODO: Is refreshing oidc token an option? ~Levi
        
        let profile = AuthenticationProviderProfile(
            email: nil,
            familyName: nil,
            givenName: nil,
            name: nil
        )
        
        let response = AuthenticationProviderResponse(
            accessToken: nil,
            appleSignInAuthorizationCode: nil,
            idToken: nil,
            oidcToken: nil,
            profile: profile,
            providerType: .facebook,
            refreshToken: nil
        )
        
        return Just(response)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func signOutPublisher() -> AnyPublisher<Void, Error> {
        
        signOut()
        
        return Just(Void())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getAuthUserPublisher() -> AnyPublisher<AuthUserDomainModel?, Error> {
        
        return FacebookProfile()
            .getCurrentUserProfilePublisher()
            .compactMap { (profile: Profile?) in
                profile?.toAuthUserDomainModel()
            }
            .eraseToAnyPublisher()
    }
}
