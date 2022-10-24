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
    private let snowplowAnalytics: SnowplowAnalytics
    
    init(cruOktaAuthentication: CruOktaAuthentication, firebaseAnalytics: FirebaseAnalytics, snowplowAnalytics: SnowplowAnalytics) {
        
        self.cruOktaAuthentication = cruOktaAuthentication
        self.firebaseAnalytics = firebaseAnalytics
        self.snowplowAnalytics = snowplowAnalytics
    }
    
    func logOutPublisher(fromViewController: UIViewController) -> AnyPublisher<Bool, Never> {
        
        return cruOktaAuthentication.signOutPublisher(fromViewController: fromViewController)
            .flatMap({ (response: OktaSignOutResponse) -> AnyPublisher<Bool, Never> in
                
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
        
        snowplowAnalytics.setLoggedInStateIdContextProperties(
            isLoggedIn: false,
            loggedInUserProperties: nil
        )
    }
}
