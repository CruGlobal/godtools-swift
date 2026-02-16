//
//  AuthenticateUserUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import Combine

final class AuthenticateUserUseCase {
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
    
    private let userAuthentication: UserAuthentication
    private let emailSignUpService: EmailSignUpService
    private let firebaseAnalytics: FirebaseAnalyticsInterface
    
    init(userAuthentication: UserAuthentication, emailSignUpService: EmailSignUpService, firebaseAnalytics: FirebaseAnalyticsInterface) {
        
        self.userAuthentication = userAuthentication
        self.emailSignUpService = emailSignUpService
        self.firebaseAnalytics = firebaseAnalytics
    }
    
    @MainActor func execute(authType: AuthenticateUserAuthTypeDomainModel, authPlatform: AuthenticateUserAuthPlatformDomainModel, authPolicy: AuthenticateUserAuthPolicyDomainModel) -> AnyPublisher<Bool, Error> {
        
        return authenticateByAuthTypePublisher(
            authType: authType,
            authPlatform: authPlatform,
            authPolicy: authPolicy
        )
        .flatMap { (token: MobileContentAuthTokenDataModel) -> AnyPublisher<AuthUserDomainModel?, Error> in
            
            return AnyPublisher() {
                
                let authUser: AuthUserDomainModel? = try await self.userAuthentication.getAuthUser()
                
                return authUser
            }
            .eraseToAnyPublisher()
        }
        .flatMap{ (authUser: AuthUserDomainModel?) -> AnyPublisher<Bool, Error> in
            
            if let authUser = authUser {
                self.postEmailSignUp(authUser: authUser)
                self.setAnalyticsUserProperties(authUser: authUser, authPlatform: authPlatform)
            }
            
            return Just(true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    @MainActor private func authenticateByAuthTypePublisher(authType: AuthenticateUserAuthTypeDomainModel, authPlatform: AuthenticateUserAuthPlatformDomainModel, authPolicy: AuthenticateUserAuthPolicyDomainModel) -> AnyPublisher<MobileContentAuthTokenDataModel, Error> {
                                
        switch authPolicy {
            
        case .renewAccessTokenElseAskUserToAuthenticate(let fromViewController):
            
            return signInPublisher(
                fromViewController: fromViewController,
                authType: authType,
                authPlatform: authPlatform
            )
            
        case .renewAccessToken:
            
            return renewTokenPublisher()
        }
    }
    
    @MainActor private func signInPublisher(fromViewController: UIViewController, authType: AuthenticateUserAuthTypeDomainModel, authPlatform: AuthenticateUserAuthPlatformDomainModel) -> AnyPublisher<MobileContentAuthTokenDataModel, Error> {
        
        // TODO: Need AuthErrorDomainModel here. ~Levi
        
        return AnyPublisher() {
            
            let result: Result<MobileContentAuthTokenDataModel, MobileContentApiError> = try await self.userAuthentication.signIn(
                provider: authPlatform.toProvider(),
                createUser: authType == .createAccount,
                fromViewController: fromViewController
            )
            
            switch result {
            case .success(let token):
                return token
                
            case .failure(let apiError):
                throw apiError
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func renewTokenPublisher() -> AnyPublisher<MobileContentAuthTokenDataModel, Error> {
        
        // TODO: Need AuthErrorDomainModel here. ~Levi
        
        return AnyPublisher() {
            
            let result: Result<MobileContentAuthTokenDataModel, MobileContentApiError> = try await self.userAuthentication.renewToken()
            
            switch result {
            case .success(let token):
                return token
                
            case .failure(let apiError):
                throw apiError
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func postEmailSignUp(authUser: AuthUserDomainModel) {
        
        let emailSignUp = EmailSignUpModel(
            email: authUser.email,
            firstName: authUser.firstName,
            lastName: authUser.lastName
        )
        
        emailSignUpService
            .postNewEmailSignUpPublisher(emailSignUp: emailSignUp, requestPriority: .medium)
            .sink { _ in
                
            }
            .store(in: &Self.backgroundCancellables)
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
