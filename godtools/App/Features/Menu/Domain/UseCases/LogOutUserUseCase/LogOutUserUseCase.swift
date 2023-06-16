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
    
    init(userAuthentication: UserAuthentication, firebaseAnalytics: FirebaseAnalytics) {
        
        self.userAuthentication = userAuthentication
        self.firebaseAnalytics = firebaseAnalytics
    }
    
    func logOutPublisher() -> AnyPublisher<Bool, Error> {
                
        return userAuthentication.signOutPublisher()
            .flatMap({ (void: Void) -> AnyPublisher<Bool, Never> in
                
                self.setAnalyticsUserProperties()
                
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
