//
//  UserAuthentication.swift
//  godtools
//
//  Created by Rachael Skeath on 11/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import OktaAuthentication
import Combine
import SocialAuthentication

class UserAuthentication {
    
    private let cruOktaAuthentication: CruOktaAuthentication
    private let facebookAuthentication: FacebookAuthentication
        
    init(cruOktaAuthentication: CruOktaAuthentication, facebookAuthentication: FacebookAuthentication) {
        
        self.cruOktaAuthentication = cruOktaAuthentication
        self.facebookAuthentication = facebookAuthentication
    }
    
    func renewOktaAccessTokenPublisher() -> AnyPublisher<String, URLResponseError> {

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
    }
}
