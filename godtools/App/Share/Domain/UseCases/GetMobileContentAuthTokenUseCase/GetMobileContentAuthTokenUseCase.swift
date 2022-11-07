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
    
    private var cancellables = Set<AnyCancellable>()
    
    init(cruOktaAuthentication: CruOktaAuthentication, mobileContentAuthTokenRepository: MobileContentAuthTokenRepository) {
        
        self.cruOktaAuthentication = cruOktaAuthentication
        self.mobileContentAuthTokenRepository = mobileContentAuthTokenRepository
    }
    
    func refreshAuthToken(with oktaAccessToken: String) {
        
        getAuthToken(with: oktaAccessToken)
            .sink { completed in
                
                switch completed {
                case .finished:
                    break
                    
                case .failure(let error):
                    
                    assertionFailure("Error refreshing token: \(error.localizedDescription)")
                }
                
            } receiveValue: { _ in }
            .store(in: &cancellables)

    }
    
    func getAuthToken() -> AnyPublisher<String?, URLResponseError> {
        
        // TODO: - this should be updated to `withFreshTokenPerformAction` based on https://github.com/okta/okta-oidc-ios/blob/e5450a3aab5c194a7470addeef176e769a374650/Sources/AppAuth/OKTAuthState.m#L90-L93
        guard let oktaAccessToken = cruOktaAuthentication.getAccessTokenFromPersistentStore() else {
            
            return Just(nil)
                .setFailureType(to: URLResponseError.self)
                .eraseToAnyPublisher()
        }
        
        return getAuthToken(with: oktaAccessToken)
    }
    
    private func getAuthToken(with oktaAccessToken: String) -> AnyPublisher<String?, URLResponseError> {
        
        return mobileContentAuthTokenRepository.getAuthTokenPublisher(oktaAccessToken: oktaAccessToken)
    }
}
