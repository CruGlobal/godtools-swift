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

extension FacebookAuthentication: AuthenticationProviderInterface {
    
    func getPersistedAccessToken() -> AuthenticationProviderAccessToken? {
        
        guard let accessToken = getAccessTokenString() else {
            return nil
        }
        
        return AuthenticationProviderAccessToken(value: accessToken)
    }
    
    func authenticatePublisher(presentingViewController: UIViewController) -> AnyPublisher<AuthenticationProviderAccessToken?, Error> {
        
        return authenticatePublisher(from: presentingViewController)
            .map { (response: FacebookAuthenticationResponse) in
                
                guard let accessToken = response.accessToken else {
                    return nil
                }
                
                return AuthenticationProviderAccessToken(value: accessToken)
            }
            .eraseToAnyPublisher()
    }
    
    func signOutPublisher() -> AnyPublisher<Void, Error> {
        
        signOut()
        
        return Just(()).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
