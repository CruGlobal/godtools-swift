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
        
        // TODO: - access token renewal will come through MobileContentAPI?
        
        return Just(AuthenticationProviderAccessToken.apple(idToken: "", givenName: "", familyName: ""))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func signOutPublisher() -> AnyPublisher<Void, Error> {
        
        return Just(()).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getAuthUserPublisher() -> AnyPublisher<AuthUserDomainModel?, Error> {
        
        // TODO: Should return an AuthUserDomainModel if user info can be obtained from AppleAuthentication. Implement in GT-2027. ~Levi
        
        return Just(nil).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
