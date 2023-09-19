//
//  AuthenticateUserUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import Combine

class AuthenticateUserUseCase {
    
    private let userAuthentication: AuthenticateUserInterface
    private let emailSignUpService: EmailSignUpService
    private let firebaseAnalytics: FirebaseAnalytics
    
    init(userAuthentication: AuthenticateUserInterface, emailSignUpService: EmailSignUpService, firebaseAnalytics: FirebaseAnalytics) {
        
        self.userAuthentication = userAuthentication
        self.emailSignUpService = emailSignUpService
        self.firebaseAnalytics = firebaseAnalytics
    }
    
    func authenticatePublisher(authType: AuthenticateUserAuthType, authPlatform: AuthenticateUserAuthPlatform, authPolicy: AuthenticateUserAuthPolicy) -> AnyPublisher<Bool, AuthErrorDomainModel> {
        
        return userAuthentication.authenticateUserPublisher(authType: authType, authPlatform: authPlatform, authPolicy: authPolicy)
            .flatMap({ (authUser: AuthUserDomainModel?) -> AnyPublisher<Bool, AuthErrorDomainModel> in
                
                if let authUser = authUser {
                    self.postEmailSignUp(authUser: authUser)
                    self.setAnalyticsUserProperties(authUser: authUser)
                }
                
                return Just(true).setFailureType(to: AuthErrorDomainModel.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func postEmailSignUp(authUser: AuthUserDomainModel) {
        
        let emailSignUp = EmailSignUpModel(
            email: authUser.email,
            firstName: authUser.firstName,
            lastName: authUser.lastName
        )
        
        _ = emailSignUpService.postNewEmailSignUpIfNeeded(emailSignUp: emailSignUp)
    }
    
    private func setAnalyticsUserProperties(authUser: AuthUserDomainModel) {
        
        firebaseAnalytics.setLoggedInStateUserProperties(
            isLoggedIn: true,
            loggedInUserProperties: FirebaseAnalyticsLoggedInUserProperties(grMasterPersonId: authUser.grMasterPersonId, ssoguid: authUser.ssoGuid)
        )
    }
}
