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
    func getPersistedAccessToken() -> AuthenticationProviderAccessToken? {
        
        // TODO: - access token renewal will come through MobileContentAPI?
        
        return nil
    }
    
    func authenticatePublisher(presentingViewController: UIViewController) -> AnyPublisher<AuthenticationProviderAccessToken?, Error> {
        
        return authenticatePublisher()
            .map { (response: AppleAuthenticationResponse) in
                
                guard
                    let idToken = response.identityToken,
                    let givenName = response.fullName?.givenName,
                    let familyName = response.fullName?.familyName
                else {
                    return nil
                }
                                
                return AuthenticationProviderAccessToken.apple(
                    idToken: idToken,
                    givenName: givenName,
                    familyName: familyName
                )
            }
            .eraseToAnyPublisher()
    }
    
    func renewAccessTokenPublisher() -> AnyPublisher<AuthenticationProviderAccessToken, Error> {
        
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