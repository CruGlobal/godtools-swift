//
//  LogOutUserUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import Combine

class LogOutUserUseCase {
    
    private let userAuthentication: UserAuthentication
    private let firebaseAnalytics: FirebaseAnalytics
    private let mobileContentAuthTokenRepository: MobileContentAuthTokenRepository
    
    init(userAuthentication: UserAuthentication, firebaseAnalytics: FirebaseAnalytics, mobileContentAuthTokenRepository: MobileContentAuthTokenRepository) {
        
        self.userAuthentication = userAuthentication
        self.firebaseAnalytics = firebaseAnalytics
        self.mobileContentAuthTokenRepository = mobileContentAuthTokenRepository
    }
    
    func logOutPublisher(fromViewController: UIViewController) -> AnyPublisher<Bool, Error> {
                
        return userAuthentication.signOutPublisher(fromViewController: fromViewController)
            .flatMap({ (void: Void) -> AnyPublisher<Bool, Never> in
                
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
