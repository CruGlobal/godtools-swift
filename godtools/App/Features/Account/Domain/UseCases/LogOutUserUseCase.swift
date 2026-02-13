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
    private let firebaseAnalytics: FirebaseAnalyticsInterface
    private let deleteUserCountersUseCase: DeleteUserCountersUseCase
    
    init(userAuthentication: UserAuthentication, firebaseAnalytics: FirebaseAnalyticsInterface, deleteUserCountersUseCase: DeleteUserCountersUseCase) {
        
        self.userAuthentication = userAuthentication
        self.firebaseAnalytics = firebaseAnalytics
        self.deleteUserCountersUseCase = deleteUserCountersUseCase
    }
    
    func logOutPublisher() -> AnyPublisher<Bool, Error> {
                
        userAuthentication.signOut()
        
        setAnalyticsUserProperties()
        
        return deleteUserCountersUseCase
            .deleteUserCountersPublisher()
            .map { _ in
                return true
            }
            .catch({ error in
                return Just(false)
                    .setFailureType(to: Error.self)
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
