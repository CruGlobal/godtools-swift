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
    
    private let authenticateUser: AuthenticateUserInterface
    private let emailSignUpService: EmailSignUpService
    private let firebaseAnalytics: FirebaseAnalytics
    
    init(authenticateUser: AuthenticateUserInterface, emailSignUpService: EmailSignUpService, firebaseAnalytics: FirebaseAnalytics) {
        
        self.authenticateUser = authenticateUser
        self.emailSignUpService = emailSignUpService
        self.firebaseAnalytics = firebaseAnalytics
    }
    
    func authenticatePublisher(authType: AuthenticateUserAuthTypeDomainModel, authPlatform: AuthenticateUserAuthPlatformDomainModel, authPolicy: AuthenticateUserAuthPolicyDomainModel) -> AnyPublisher<Bool, AuthErrorDomainModel> {
        
        return authenticateUser.authenticateUserPublisher(authType: authType, authPlatform: authPlatform, authPolicy: authPolicy)
            .flatMap({ (authUser: AuthUserDomainModel?) -> AnyPublisher<Bool, AuthErrorDomainModel> in
                
                if let authUser = authUser {
                    self.postEmailSignUp(authUser: authUser)
                    self.setAnalyticsUserProperties(authUser: authUser, authPlatform: authPlatform)
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
    
    private func setAnalyticsUserProperties(authUser: AuthUserDomainModel, authPlatform: AuthenticateUserAuthPlatformDomainModel) {
        
        let loginProvider: String
        
        switch authPlatform {
        case .apple:
            loginProvider = AnalyticsConstants.UserProperties.loginProviderApple
        case .facebook:
            loginProvider = AnalyticsConstants.UserProperties.loginProviderFacebook
        case .google:
            loginProvider = AnalyticsConstants.UserProperties.loginProviderGoogle
        }
        
        firebaseAnalytics.setLoggedInStateUserProperties(
            isLoggedIn: true,
            loggedInUserProperties: FirebaseAnalyticsLoggedInUserProperties(
                grMasterPersonId: authUser.grMasterPersonId,
                loginProvider: loginProvider,
                ssoguid: authUser.ssoGuid
            )
        )
    }
}
