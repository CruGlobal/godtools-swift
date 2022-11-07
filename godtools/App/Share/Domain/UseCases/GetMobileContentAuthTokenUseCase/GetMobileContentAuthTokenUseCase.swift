//
//  GetMobileContentAuthTokenUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/7/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import OktaAuthentication
import Combine

class GetMobileContentAuthTokenUseCase {
    
    private let cruOktaAuthentication: CruOktaAuthentication
    private let mobileContentAuthTokenRepository: MobileContentAuthTokenRepository
    
    init(cruOktaAuthentication: CruOktaAuthentication, mobileContentAuthTokenRepository: MobileContentAuthTokenRepository) {
        
        self.cruOktaAuthentication = cruOktaAuthentication
        self.mobileContentAuthTokenRepository = mobileContentAuthTokenRepository
    }
    
    public func getAuthToken() -> AnyPublisher<String?, URLResponseError> {
        
        // TODO: - this should be updated to `withFreshTokenPerformAction` based on https://github.com/okta/okta-oidc-ios/blob/e5450a3aab5c194a7470addeef176e769a374650/Sources/AppAuth/OKTAuthState.m#L90-L93
        guard let oktaAccessToken = cruOktaAuthentication.getAccessTokenFromPersistentStore() else {
            
            return Just(nil)
                .setFailureType(to: URLResponseError.self)
                .eraseToAnyPublisher()
        }
        
        return mobileContentAuthTokenRepository.getAuthTokenPublisher(oktaAccessToken: oktaAccessToken)
    }
}
