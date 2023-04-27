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
    
    func authenticatePublisher(authType: AuthenticateUserAuthTypeDomainModel) -> AnyPublisher<Bool, Error> {
        
        return Just(true).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // Uncomment and implement in GT-2012. ~Levi
        
        /*
        return authenticateByAuthTypePublisher(authType: authType)
            .flatMap({ (success: Bool) -> AnyPublisher<CruOktaUserDataModel, Error> in
                                
                return self.cruOktaAuthentication.getAuthUserPublisher()
                    .mapError { oktaError in
                        return oktaError.getError()
                    }
                    .eraseToAnyPublisher()
            })
            .flatMap({ (authUser: CruOktaUserDataModel) -> AnyPublisher<Bool, Error> in
                
                self.postEmailSignUp(authUser: authUser)
                self.setAnalyticsUserProperties(authUser: authUser)
                
                return Just(true).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
         */
    }
    
    private func authenticateByAuthTypePublisher(authType: AuthenticateUserAuthTypeDomainModel) -> AnyPublisher<Bool, Error> {
        
        return Just(true).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // Uncomment and implement in GT-2012. ~Levi
        
        /*
        switch authType {
            
        case .attemptToRenewAuthenticationElseAuthenticate(let fromViewController):
            
            return cruOktaAuthentication.signInPublisher(fromViewController: fromViewController)
                .setFailureType(to: Error.self)
                .flatMap({ (response: OktaAuthenticationResponse) -> AnyPublisher<OktaAccessToken, Error> in
                    
                    return response.result.publisher
                        .mapError { oktaError in
                            return oktaError.getError()
                        }
                        .eraseToAnyPublisher()
                })
                .map { (oktaAccessToken: OktaAccessToken) in
                    return true
                }
                .eraseToAnyPublisher()
            
        case .attemptToRenewAuthenticationOnly:
            
            return cruOktaAuthentication.renewAccessTokenPublisher()
                .setFailureType(to: Error.self)
                .flatMap({ (response: OktaAuthenticationResponse) -> AnyPublisher<OktaAccessToken, Error> in
                    
                    return response.result.publisher
                        .mapError { oktaError in
                            return oktaError.getError()
                        }
                        .eraseToAnyPublisher()
                })
                .map { (oktaAccessToken: OktaAccessToken) in
                    return true
                }
                .eraseToAnyPublisher()
        }*/
    }
    
    private func postEmailSignUp(authUser: AuthenticatedUserInterface) {
        
        let emailSignUp = EmailSignUpModel(
            email: authUser.email,
            firstName: authUser.firstName,
            lastName: authUser.lastName
        )
        
        _ = emailSignUpService.postNewEmailSignUpIfNeeded(emailSignUp: emailSignUp)
    }
    
    private func setAnalyticsUserProperties(authUser: AuthenticatedUserInterface) {
        
        firebaseAnalytics.setLoggedInStateUserProperties(
            isLoggedIn: true,
            loggedInUserProperties: FirebaseAnalyticsLoggedInUserProperties(grMasterPersonId: authUser.grMasterPersonId, ssoguid: authUser.ssoGuid)
        )
    }
}
