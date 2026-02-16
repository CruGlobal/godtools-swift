//
//  LogOutUserUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import Combine

final class LogOutUserUseCase {
    
    private let userAuthentication: UserAuthentication
    private let firebaseAnalytics: FirebaseAnalyticsInterface
    private let userCountersRepository: UserCountersRepository
    
    init(userAuthentication: UserAuthentication, firebaseAnalytics: FirebaseAnalyticsInterface, userCountersRepository: UserCountersRepository) {
        
        self.userAuthentication = userAuthentication
        self.firebaseAnalytics = firebaseAnalytics
        self.userCountersRepository = userCountersRepository
    }
    
    func execute() -> AnyPublisher<Bool, Error> {
                
        userAuthentication.signOut()
        
        setAnalyticsUserProperties()
        
        do {
            
            try userCountersRepository.deleteUserCounters()
            
            return Just(true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        catch let error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    private func setAnalyticsUserProperties() {
        
        firebaseAnalytics.setLoggedInStateUserProperties(
            isLoggedIn: false,
            loggedInUserProperties: nil
        )
    }
}
