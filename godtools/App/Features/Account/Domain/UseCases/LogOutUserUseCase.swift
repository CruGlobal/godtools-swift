//
//  LogOutUserUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

final class LogOutUserUseCase: Sendable {
    
    private let userAuthentication: UserAuthentication
    private let firebaseAnalytics: FirebaseAnalyticsInterface
    private let userCountersRepository: UserCountersRepository
    
    init(
        userAuthentication: UserAuthentication,
        firebaseAnalytics: FirebaseAnalyticsInterface,
        userCountersRepository: UserCountersRepository
    ) {
        
        self.userAuthentication = userAuthentication
        self.firebaseAnalytics = firebaseAnalytics
        self.userCountersRepository = userCountersRepository
    }
    
    func execute() async throws -> Bool {
        
        try await userCountersRepository.deleteCounters()
        
        try await userAuthentication.signOut()
        
        await setAnalyticsUserProperties()
        
        return true
    }
    
    private func setAnalyticsUserProperties() async {
        
        await firebaseAnalytics.setLoggedInStateUserProperties(
            isLoggedIn: false,
            loggedInUserProperties: nil
        )
    }
}
