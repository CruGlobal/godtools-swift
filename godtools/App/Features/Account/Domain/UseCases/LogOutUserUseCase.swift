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
                
        return signOutPublisher()
            .flatMap { (void: Void) in
                
                self.setAnalyticsUserProperties()
                
                return self.userCountersRepository
                    .deleteUserCountersPublisher()
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
    
    private func signOutPublisher() -> AnyPublisher<Void, Error> {
        
        do {
            try userAuthentication.signOut()
        }
        catch let error {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return Just(Void())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func setAnalyticsUserProperties() {
        
        firebaseAnalytics.setLoggedInStateUserProperties(
            isLoggedIn: false,
            loggedInUserProperties: nil
        )
    }
}
