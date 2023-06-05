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
    private let mobileContentAuthTokenRepository: MobileContentAuthTokenRepository
    
    init(userAuthentication: UserAuthentication, emailSignUpService: EmailSignUpService, firebaseAnalytics: FirebaseAnalytics, mobileContentAuthTokenRepository: MobileContentAuthTokenRepository) {
        
        self.userAuthentication = userAuthentication
        self.emailSignUpService = emailSignUpService
        self.firebaseAnalytics = firebaseAnalytics
        self.mobileContentAuthTokenRepository = mobileContentAuthTokenRepository
    }
    
    func authenticatePublisher(provider: AuthenticationProviderType, policy: AuthenticationPolicy, createUser: Bool = false) -> AnyPublisher<Bool, Error> {
                        
        return authenticateByAuthTypePublisher(provider: provider, policy: policy)
            .flatMap({ (authProviderResponse: AuthenticationProviderResponse) -> AnyPublisher<Bool, Error> in
                
                return self.authenticateWithMobileContentApi(authProviderResponse: authProviderResponse, createUser: createUser)
                
            })
            .flatMap({ (success: Bool) -> AnyPublisher<AuthUserDomainModel?, Error> in
                                
                return self.userAuthentication.getAuthUserPublisher()
                    .eraseToAnyPublisher()
            })
            .flatMap({ (authUser: AuthUserDomainModel?) -> AnyPublisher<Bool, Error> in
                
                if let authUser = authUser {
                    self.postEmailSignUp(authUser: authUser)
                    self.setAnalyticsUserProperties(authUser: authUser)
                }
                
                return Just(true).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func authenticateByAuthTypePublisher(provider: AuthenticationProviderType, policy: AuthenticationPolicy) -> AnyPublisher<AuthenticationProviderResponse, Error> {
                                
        switch policy {
            
        case .renewAccessTokenElseAskUserToAuthenticate(let fromViewController):
            
            return userAuthentication.signInPublisher(provider: provider, fromViewController: fromViewController)
                .eraseToAnyPublisher()
            
        case .renewAccessToken:
            
            return userAuthentication.renewAccessTokenPublisher()
                .eraseToAnyPublisher()
        }
    }
    
    private func authenticateWithMobileContentApi(authProviderResponse: AuthenticationProviderResponse, createUser: Bool) -> AnyPublisher<Bool, Error> {
        
        return mobileContentAuthTokenRepository.fetchRemoteAuthTokenPublisher(
            authToken: authProviderResponse.getMobileContentAuthToken(),
            createUser: createUser
        )
        .map { (authTokenDataModel: MobileContentAuthTokenDataModel) in
            
            return true
        }
        .mapError { urlResponseError in
            
            return urlResponseError as Error
        }
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
