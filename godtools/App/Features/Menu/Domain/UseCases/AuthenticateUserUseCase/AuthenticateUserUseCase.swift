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
    
    private let userAuthentication: UserAuthentication
    private let emailSignUpService: EmailSignUpService
    private let firebaseAnalytics: FirebaseAnalytics
    
    init(userAuthentication: UserAuthentication, emailSignUpService: EmailSignUpService, firebaseAnalytics: FirebaseAnalytics) {
        
        self.userAuthentication = userAuthentication
        self.emailSignUpService = emailSignUpService
        self.firebaseAnalytics = firebaseAnalytics
    }
    
    func authenticatePublisher(policy: AuthenticationPolicy) -> AnyPublisher<Bool, Error> {
                
        // TODO: Uncomment and implement in GT-2012. ~Levi
        
        return authenticateByAuthTypePublisher(policy: policy)
            .flatMap({ (success: Bool) -> AnyPublisher<AuthUserDomainModel, Error> in
                                
                return self.userAuthentication.getAuthUserPublisher()
                    .eraseToAnyPublisher()
            })
            .flatMap({ (authUser: AuthUserDomainModel) -> AnyPublisher<Bool, Error> in
                
                self.postEmailSignUp(authUser: authUser)
                self.setAnalyticsUserProperties(authUser: authUser)
                
                return Just(true).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func authenticateByAuthTypePublisher(policy: AuthenticationPolicy) -> AnyPublisher<Bool, Error> {
                
        // TODO: Implement in GT-2012. ~Levi
        
        switch policy {
            
        case .renewAccessTokenElseAskUserToAuthenticate(let fromViewController):
            
            return userAuthentication.signInPublisher(fromViewController: fromViewController)
                .map { (void: Void) in
                    return true
                }
                .eraseToAnyPublisher()
            
        case .renewAccessToken:
            
            return userAuthentication.renewAccessTokenPublisher()
                .flatMap({ (token: String) -> AnyPublisher<Bool, Never> in
                    return Just(true)
                        .eraseToAnyPublisher()
                })
                .eraseToAnyPublisher()
        }
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
