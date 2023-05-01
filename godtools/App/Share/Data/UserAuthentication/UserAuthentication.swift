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
    
    func getPersistedAccessToken() -> String? {
        return nil
    }
    
    func renewAccessTokenPublisher() -> AnyPublisher<String, Error> {

        return Just("").setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
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
    
    func getAuthUserPublisher() -> AnyPublisher<AuthUserDomainModel, Error> {
        
        let authUser = AuthUserDomainModel(email: "", firstName: nil, grMasterPersonId: nil, lastName: nil, ssoGuid: nil)
        
        return Just(authUser).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func signInPublisher(fromViewController: UIViewController) -> AnyPublisher<Void, Error> {
        
        return Just(()).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func signOutPublisher(fromViewController: UIViewController) -> AnyPublisher<Void, Never> {
        
        return Just(())
            .eraseToAnyPublisher()
    }
}
