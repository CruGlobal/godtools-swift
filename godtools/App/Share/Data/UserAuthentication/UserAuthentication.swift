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

class UserAuthentication {
    
    private let cruOktaAuthentication: CruOktaAuthentication
        
    init(cruOktaAuthentication: CruOktaAuthentication) {
        
        self.cruOktaAuthentication = cruOktaAuthentication
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
