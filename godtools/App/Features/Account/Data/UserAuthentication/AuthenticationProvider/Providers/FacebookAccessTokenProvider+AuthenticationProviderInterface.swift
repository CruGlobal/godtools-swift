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
    
    private func getResponseForPersistedData() -> Result<AuthenticationProviderResponse, Error> {
        
        guard let accessToken = getAccessToken(), let profile = FacebookProfile.current else {
            
            let error: Error = NSError.errorWithDescription(description: "Data not persisted.")
            
            return .failure(error)
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
        
        return .success(response)
    }
    
    func authenticatePublisher(presentingViewController: UIViewController) -> AnyPublisher<AuthenticationProviderResponse, Error> {
        
        return authenticatePublisher(from: presentingViewController)
            .flatMap({ (response: FacebookAccessTokenProviderResponse) -> AnyPublisher<AuthenticationProviderResponse, Error> in
                
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
        
        return FacebookProfile()
            .getCurrentUserProfilePublisher()
            .compactMap { (profile: Profile?) in
                profile?.toAuthUserDomainModel()
            }
            .eraseToAnyPublisher()
    }
}
