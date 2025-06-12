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
    private let deleteUserCountersUseCase: DeleteUserCountersUseCase
    
    init(userAuthentication: UserAuthentication, firebaseAnalytics: FirebaseAnalytics, deleteUserCountersUseCase: DeleteUserCountersUseCase) {
        
        self.userAuthentication = userAuthentication
        self.firebaseAnalytics = firebaseAnalytics
        self.deleteUserCountersUseCase = deleteUserCountersUseCase
    }
    
    func logOutPublisher() -> AnyPublisher<Bool, Error> {
                
        return userAuthentication.signOutPublisher()
            .flatMap { (void: Void) in
                
                self.setAnalyticsUserProperties()
                
                return self.deleteUserCountersUseCase.deleteUserCountersPublisher()
                    .flatMap { void in
                        
                        return Just(true)
                            .eraseToAnyPublisher()
                    }
                    .catch({ error in
                        
                        return Just(false)
                            .eraseToAnyPublisher()
                    })
            }
            .eraseToAnyPublisher()
    }
    
    private func setAnalyticsUserProperties() {
        
        firebaseAnalytics.setLoggedInStateUserProperties(
            isLoggedIn: false,
            loggedInUserProperties: nil
        )
    }
}
