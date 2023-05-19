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
    
    func getPersistedAccessToken() -> AuthenticationProviderAccessToken? {
        
        guard let persistedIdToken = getPersistedIdTokenString() else {
            return nil
        }
        
        return  .google(idToken: persistedIdToken)
    }
    
    func authenticatePublisher(presentingViewController: UIViewController) -> AnyPublisher<AuthenticationProviderAccessToken?, Error> {
        
        return authenticatePublisher(from: presentingViewController)
            .map { (response: GoogleAuthenticationResponse) in
                
                guard let idToken = response.idToken else {
                    return nil
                }
                
                return AuthenticationProviderAccessToken.google(idToken: idToken)
            }
            .eraseToAnyPublisher()
    }
    
    func renewAccessTokenPublisher() -> AnyPublisher<AuthenticationProviderAccessToken, Error> {
        
        return restorePreviousSignIn()
            .flatMap({ (response: GoogleAuthenticationResponse) -> AnyPublisher<AuthenticationProviderAccessToken, Error> in
                
                guard let idToken = response.idToken else {
                    return Fail(error: NSError.errorWithDescription(description: "Unable to refresh access token."))
                        .eraseToAnyPublisher()
                }
                
                let accessToken = AuthenticationProviderAccessToken.google(idToken: idToken)
                
                return Just(accessToken).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func signOutPublisher() -> AnyPublisher<Void, Error> {
        
        signOut()
        
        return Just(()).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getAuthUserPublisher() -> AnyPublisher<AuthUserDomainModel?, Error> {
        
        let authUser: AuthUserDomainModel?
        
        if let profile = getCurrentUserProfile() {
        
            authUser = mapProfileToAuthUser(profile: profile)
        }
        else {
            
            authUser = nil
        }
        
        return Just(authUser).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func mapProfileToAuthUser(profile: GIDProfileData) -> AuthUserDomainModel {
        
        return AuthUserDomainModel(
            email: profile.email,
            firstName: profile.givenName,
            grMasterPersonId: nil,
            lastName: profile.familyName,
            ssoGuid: nil
        )
    }
}
