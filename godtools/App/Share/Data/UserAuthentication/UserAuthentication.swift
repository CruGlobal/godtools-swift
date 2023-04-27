//
//  UserAuthentication.swift
//  godtools
//
//  Created by Rachael Skeath on 11/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import Combine
import SocialAuthentication

class UserAuthentication {
    
    private let facebookAuthentication: FacebookAuthentication
        
    init(facebookAuthentication: FacebookAuthentication) {
        
        self.facebookAuthentication = facebookAuthentication
    }
    
    func getAccessToken() -> UserAuthenticationAccessToken? {
        // TODO: Implement in GT-2012. ~Levi
        // Should return persisted access token.  We may need to track which social sign in a user last used?
        return nil
    }
    
    func renewOktaAccessTokenPublisher() -> AnyPublisher<String, URLResponseError> {

        return Just("").setFailureType(to: URLResponseError.self)
            .eraseToAnyPublisher()
        
        // TODO: Uncomment and implement in GT-2012. ~Levi
        
        /*
        
        return cruOktaAuthentication.renewAccessTokenPublisher()
            .flatMap { (response: OktaAuthenticationResponse) in
                
                return response.result.publisher
                    .mapError({ oktaError in
                        return URLResponseError.otherError(error: oktaError)
                    })
                    .eraseToAnyPublisher()
            }
            .flatMap { oktaAccessToken in
                
                return Just(oktaAccessToken.value)
            }
            .eraseToAnyPublisher()
         
         */
    }
    
    func signOutPublisher(fromViewController: UIViewController) -> AnyPublisher<Void, Never> {
        
        // TODO: Implement in GT-2012. ~Levi
        // Should revoke any access tokens.
        
        return Just(())
            .eraseToAnyPublisher()
    }
    
    func getAuthenticatedUserPublisher() -> AnyPublisher<AuthenticatedUserInterface?, Error> {
        
        // TODO: Implement in GT-2012. ~Levi
        // Need to see what user information we can obtain from social sdks.
        
        return Just(nil).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
