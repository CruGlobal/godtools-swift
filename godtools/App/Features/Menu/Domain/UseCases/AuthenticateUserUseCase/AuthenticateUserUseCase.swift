//
//  AuthenticateUserUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import OktaAuthentication
import Combine

class AuthenticateUserUseCase {
    
    private let cruOktaAuthentication: CruOktaAuthentication
    private let emailSignUpService: EmailSignUpService
    private let firebaseAnalytics: FirebaseAnalytics
    private let snowplowAnalytics: SnowplowAnalytics
    
    init(cruOktaAuthentication: CruOktaAuthentication, emailSignUpService: EmailSignUpService, firebaseAnalytics: FirebaseAnalytics, snowplowAnalytics: SnowplowAnalytics) {
        
        self.cruOktaAuthentication = cruOktaAuthentication
        self.emailSignUpService = emailSignUpService
        self.firebaseAnalytics = firebaseAnalytics
        self.snowplowAnalytics = snowplowAnalytics
    }
    
    func authenticatePublisher(authType: AuthenticateUserAuthTypeDomainModel) -> AnyPublisher<Bool, Error> {
        
        return authenticateByAuthTypePublisher(authType: authType)
            .flatMap({ (accessToken: OktaAccessToken) -> AnyPublisher<CruOktaUserDataModel, Error> in
                
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
    }
    
    private func authenticateByAuthTypePublisher(authType: AuthenticateUserAuthTypeDomainModel) -> AnyPublisher<OktaAccessToken, Error> {
        
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
                .eraseToAnyPublisher()
        }
    }
    
    private func postEmailSignUp(authUser: CruOktaUserDataModel) {
        
        let emailSignUp = EmailSignUpModel(
            email: authUser.email,
            firstName: authUser.firstName,
            lastName: authUser.lastName
        )
        
        _ = emailSignUpService.postNewEmailSignUpIfNeeded(emailSignUp: emailSignUp)
    }
    
    private func setAnalyticsUserProperties(authUser: CruOktaUserDataModel) {
        
        firebaseAnalytics.setLoggedInStateUserProperties(
            isLoggedIn: true,
            loggedInUserProperties: FirebaseAnalyticsLoggedInUserProperties(grMasterPersonId: authUser.grMasterPersonId, ssoguid: authUser.ssoGuid)
        )
        
        snowplowAnalytics.setLoggedInStateIdContextProperties(
            isLoggedIn: true,
            loggedInUserProperties: SnowplowAnalyticsLoggedInUserProperties(grMasterPersonId: authUser.grMasterPersonId, ssoguid: authUser.ssoGuid)
        )
    }
}
