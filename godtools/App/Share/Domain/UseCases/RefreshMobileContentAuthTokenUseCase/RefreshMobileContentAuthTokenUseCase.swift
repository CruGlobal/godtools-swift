//
//  RefreshMobileContentAuthTokenUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/1/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import OktaAuthentication
import Combine

class RefreshMobileContentAuthTokenUseCase {
    
    private let mobileContentAuthTokenRepository: MobileContentAuthTokenRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(mobileContentAuthTokenRepository: MobileContentAuthTokenRepository) {
        
        self.mobileContentAuthTokenRepository = mobileContentAuthTokenRepository
    }
    
    func refreshAuthToken(oktaAccessToken: OktaAccessToken) {
        
        mobileContentAuthTokenRepository.requestAuthTokenPublisher(oktaAccessToken)
            .sink { _ in
            } receiveValue: { value in
                print("here")
            }
            .store(in: &cancellables)

    }
}
