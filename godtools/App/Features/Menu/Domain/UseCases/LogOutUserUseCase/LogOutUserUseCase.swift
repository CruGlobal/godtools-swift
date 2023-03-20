//
//  LogOutUserUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import OktaAuthentication
import Combine

class LogOutUserUseCase {
    
    private let cruOktaAuthentication: CruOktaAuthentication
    private let firebaseAnalytics: FirebaseAnalytics
    private let mobileContentAuthTokenRepository: MobileContentAuthTokenRepository
    
    init(cruOktaAuthentication: CruOktaAuthentication, firebaseAnalytics: FirebaseAnalytics, mobileContentAuthTokenRepository: MobileContentAuthTokenRepository) {
        
        self.cruOktaAuthentication = cruOktaAuthentication
        self.firebaseAnalytics = firebaseAnalytics
        self.mobileContentAuthTokenRepository = mobileContentAuthTokenRepository
    }
    
    func logOutPublisher(fromViewController: UIViewController) -> AnyPublisher<Bool, Never> {
        
        return cruOktaAuthentication.signOutPublisher(fromViewController: fromViewController)
            .flatMap({ (response: OktaSignOutResponse) -> AnyPublisher<Bool, Never> in
                
                self.setAnalyticsUserProperties()
                self.mobileContentAuthTokenRepository.deleteCachedAuthToken()
                
                return Just(true)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func setAnalyticsUserProperties() {
        
        firebaseAnalytics.setLoggedInStateUserProperties(
            isLoggedIn: false,
            loggedInUserProperties: nil
        )
    }
}
