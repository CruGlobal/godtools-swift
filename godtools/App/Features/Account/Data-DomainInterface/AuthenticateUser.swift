//
//  AuthenticateUser.swift
//  godtools
//
//  Created by Levi Eggert on 11/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class AuthenticateUser: AuthenticateUserInterface {
    
    private let userAuthentication: UserAuthentication
    
    init(userAuthentication: UserAuthentication) {
        
        self.userAuthentication = userAuthentication
    }
    
    func authenticateUserPublisher(authType: AuthenticateUserAuthTypeDomainModel, authPlatform: AuthenticateUserAuthPlatformDomainModel, authPolicy: AuthenticateUserAuthPolicyDomainModel) -> AnyPublisher<AuthUserDomainModel?, AuthErrorDomainModel> {
        
        return authenticateByAuthTypePublisher(
            authType: authType,
            authPlatform: authPlatform,
            authPolicy: authPolicy
        )
        .flatMap({ (authToken: MobileContentAuthTokenDataModel) -> AnyPublisher<AuthUserDomainModel?, AuthErrorDomainModel> in
                            
            return self.userAuthentication.getAuthUserPublisher()
                .mapError { (error: Error) in
                    return .other(error: error)
                }
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    private func authenticateByAuthTypePublisher(authType: AuthenticateUserAuthTypeDomainModel, authPlatform: AuthenticateUserAuthPlatformDomainModel, authPolicy: AuthenticateUserAuthPolicyDomainModel) -> AnyPublisher<MobileContentAuthTokenDataModel, AuthErrorDomainModel> {
                                
        switch authPolicy {
            
        case .renewAccessTokenElseAskUserToAuthenticate(let fromViewController):
                        
            return userAuthentication.signInPublisher(
                provider: self.mapAuthPlatformToProvider(authPlatform: authPlatform),
                createUser: authType == .createAccount,
                fromViewController: fromViewController
            )
            .mapError { (apiError: MobileContentApiError) in
                return self.mapApiErrorToAuthErrorDomainModel(apiError: apiError)
            }
            .eraseToAnyPublisher()
            
        case .renewAccessToken:
            
            return userAuthentication.renewTokenPublisher()
                .mapError { (apiError: MobileContentApiError) in
                    return self.mapApiErrorToAuthErrorDomainModel(apiError: apiError)
                }
                .eraseToAnyPublisher()
        }
    }
    
    func renewAuthenticationPublisher() -> AnyPublisher<AuthUserDomainModel?, AuthErrorDomainModel> {
        
        return userAuthentication.renewTokenPublisher()
            .mapError { (apiError: MobileContentApiError) in
                return self.mapApiErrorToAuthErrorDomainModel(apiError: apiError)
            }
            .flatMap({ (authToken: MobileContentAuthTokenDataModel) -> AnyPublisher<AuthUserDomainModel?, AuthErrorDomainModel> in
                                
                return self.userAuthentication.getAuthUserPublisher()
                    .mapError { (error: Error) in
                        return .other(error: error)
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func mapApiErrorToAuthErrorDomainModel(apiError: MobileContentApiError) -> AuthErrorDomainModel {
        
        switch apiError {
            
        case .other(let error):
            return .other(error: error)
            
        case .responseError(let responseErrors, let error):
            
            for responseError in responseErrors {
                
                let code: MobileContentApiErrorCodableCode = responseError.getCodeEnum()
                
                if code == .userNotFound {
                    return .accountNotFound
                }
                else if code == .userAlreadyExists {
                    return .accountAlreadyExists
                }
            }

            return .other(error: error)
        }
    }
    
    private func mapAuthPlatformToProvider(authPlatform: AuthenticateUserAuthPlatformDomainModel) -> AuthenticationProviderType {
        
        switch authPlatform {
        case .apple:
            return .apple
        case .facebook:
            return .facebook
        case .google:
            return .google
        }
    }
}
