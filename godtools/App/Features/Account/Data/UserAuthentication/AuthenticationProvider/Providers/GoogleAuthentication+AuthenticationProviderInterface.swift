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
    
    private func getResponseForPersistedData() -> Result<AuthenticationProviderResponse, Error> {
        
        guard let user = getCurrentUser(), let idToken = user.idToken?.tokenString else {
            
            let error: Error = NSError.errorWithDescription(description: "Data not persisted.")
            
            return .failure(error)
        }
        
        let response = AuthenticationProviderResponse(
            accessToken: user.accessToken.tokenString,
            appleSignInAuthorizationCode: nil,
            idToken: idToken,
            profile: AuthenticationProviderProfile(
                email: user.profile?.email,
                familyName: user.profile?.familyName,
                givenName: user.profile?.givenName,
                name: user.profile?.name
            ),
            providerType: .google,
            refreshToken: user.refreshToken.tokenString
        )
        
        return .success(response)
    }
    
    func getPersistedResponse() -> AuthenticationProviderResponse? {
        
        switch getResponseForPersistedData() {
            
        case .success(let response):
            return response
            
        case .failure( _):
            return nil
        }
    }
    
    func authenticatePublisher(presentingViewController: UIViewController) -> AnyPublisher<AuthenticationProviderResponse, Error> {
        
        return authenticatePublisher(from: presentingViewController)
            .flatMap({ (response: GoogleAuthenticationResponse) -> AnyPublisher<AuthenticationProviderResponse, Error> in
                                
                return self.getResponseForPersistedData().publisher
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func renewTokenPublisher() -> AnyPublisher<AuthenticationProviderResponse, Error> {
        
        return restorePreviousSignIn()
            .flatMap({ (response: GoogleAuthenticationResponse) -> AnyPublisher<AuthenticationProviderResponse, Error> in
                
                return self.getResponseForPersistedData().publisher
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
            name: profile.name,
            ssoGuid: nil
        )
    }
}
