//
//  FacebookAuthentication+AuthenticationProviderInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit
import SocialAuthentication
import Combine
import FBSDKLoginKit

extension FacebookAuthentication: AuthenticationProviderInterface {
    
    func getPersistedAccessToken() -> AuthenticationProviderAccessToken? {
        
        guard let accessToken = getAccessTokenString() else {
            return nil
        }
        
        return AuthenticationProviderAccessToken.facebook(accessToken: accessToken)
    }
    
    func authenticatePublisher(presentingViewController: UIViewController) -> AnyPublisher<AuthenticationProviderAccessToken?, Error> {
        
        return authenticatePublisher(from: presentingViewController)
            .map { (response: FacebookAuthenticationResponse) in
                
                guard let accessToken = response.accessToken else {
                    return nil
                }
                
                return AuthenticationProviderAccessToken.facebook(accessToken: accessToken)
            }
            .eraseToAnyPublisher()
    }
    
    func renewAccessTokenPublisher() -> AnyPublisher<AuthenticationProviderAccessToken, Error> {
        
        return refreshCurrentAccessTokenPublisher()
            .flatMap({ (void: Void) -> AnyPublisher<AuthenticationProviderAccessToken, Error> in
                
                if let providerAccessToken = self.getPersistedAccessToken() {
                    return Just(providerAccessToken).setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                else {
                    return Fail(error: NSError.errorWithDescription(description: "Unable to refresh access token."))
                        .eraseToAnyPublisher()
                }
            })
            .eraseToAnyPublisher()
    }
    
    func signOutPublisher() -> AnyPublisher<Void, Error> {
        
        signOut()
        
        return Just(()).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getAuthUserPublisher() -> AnyPublisher<AuthUserDomainModel?, Error> {
                
        if let profile = getCurrentUserProfile() {
                    
            return Just(mapProfileToAuthUser(profile: profile)).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return loadUserProfilePublisher()
            .map { (profile: Profile?) in
                
                if let profile = profile {
                    return self.mapProfileToAuthUser(profile: profile)
                }
                
                return nil
            }
            .eraseToAnyPublisher()
    }
    
    private func mapProfileToAuthUser(profile: Profile) -> AuthUserDomainModel {
        
        return  AuthUserDomainModel(
            email: profile.email ?? "",
            firstName: profile.firstName,
            grMasterPersonId: nil,
            lastName: profile.lastName,
            ssoGuid: nil
        )
    }
}
