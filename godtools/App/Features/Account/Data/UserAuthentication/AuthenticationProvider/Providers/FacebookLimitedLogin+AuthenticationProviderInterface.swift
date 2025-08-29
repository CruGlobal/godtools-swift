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
            .flatMap({ (response: FacebookLimitedLoginResponse) -> AnyPublisher<(response: FacebookLimitedLoginResponse, profile: Profile?), Never> in
                
                return FacebookProfile()
                    .getCurrentUserProfilePublisher()
                    .catch { (error: Error) in
                        return Just(nil)
                            .eraseToAnyPublisher()
                    }
                    .map { (profile: Profile?) in
                        return (response: response, profile: profile)
                    }
                    .eraseToAnyPublisher()
            })
            .map { (response: FacebookLimitedLoginResponse, profile: Profile?) in
                   
                let providerProfile: AuthenticationProviderProfile = profile?.toAuthProviderProfile() ?? AuthenticationProviderProfile.emptyProfile

                return AuthenticationProviderResponse(
                    accessToken: nil,
                    appleSignInAuthorizationCode: nil,
                    idToken: nil,
                    oidcToken: response.oidcToken,
                    profile: providerProfile,
                    providerType: .facebook,
                    refreshToken: nil
                )
            }
            .eraseToAnyPublisher()
    }
    
    func renewTokenPublisher() -> AnyPublisher<AuthenticationProviderResponse, Error> {
        
        return FacebookProfile()
            .getCurrentUserProfilePublisher()
            .catch { (error: Error) in
                return Just(nil)
                    .eraseToAnyPublisher()
            }
            .flatMap({ (profile: Profile?) -> AnyPublisher<AuthenticationProviderResponse, Error> in

                let providerProfile: AuthenticationProviderProfile = profile?.toAuthProviderProfile() ?? AuthenticationProviderProfile.emptyProfile
                
                let oidcToken: String? = self.getAuthenticationTokenString()
                
                let response = AuthenticationProviderResponse(
                    accessToken: nil,
                    appleSignInAuthorizationCode: nil,
                    idToken: nil,
                    oidcToken: oidcToken,
                    profile: providerProfile,
                    providerType: .facebook,
                    refreshToken: nil
                )
                
                return Just(response)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
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
