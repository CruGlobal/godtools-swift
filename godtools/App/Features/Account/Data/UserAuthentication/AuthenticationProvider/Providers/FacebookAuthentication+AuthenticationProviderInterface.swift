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
    
    private func getResponseForPersistedData() -> Result<AuthenticationProviderResponse, Error> {
        
        guard let accessToken = getAccessToken(), let profile = getCurrentUserProfile() else {
            
            let error: Error = NSError.errorWithDescription(description: "Data not persisted.")
            
            return .failure(error)
        }
        
        let response = AuthenticationProviderResponse(
            accessToken: accessToken.tokenString,
            appleSignInAuthorizationCode: nil,
            idToken: nil,
            profile: AuthenticationProviderProfile(
                email: profile.email,
                familyName: profile.lastName,
                givenName: profile.firstName,
                name: profile.name
            ),
            providerType: .facebook,
            refreshToken: nil
        )
        
        return .success(response)
    }
    
    func authenticatePublisher(presentingViewController: UIViewController) -> AnyPublisher<AuthenticationProviderResponse, Error> {
        
        return authenticatePublisher(from: presentingViewController)
            .flatMap({ (response: FacebookAuthenticationResponse) -> AnyPublisher<AuthenticationProviderResponse, Error> in
                
                if response.isCancelled {
                    return Fail(error: NSError.userCancelledError())
                        .eraseToAnyPublisher()
                }
                
                return self.getResponseForPersistedData().publisher
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func renewTokenPublisher() -> AnyPublisher<AuthenticationProviderResponse, Error> {
        
        return refreshCurrentAccessTokenPublisher()
            .flatMap({ (void: Void) -> AnyPublisher<AuthenticationProviderResponse, Error> in
                
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
            name: profile.name,
            ssoGuid: nil
        )
    }
}
