//
//  UserAuthentication+AuthenticateUserInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine

extension UserAuthentication: AuthenticateUserInterface {
    
    func authenticateUserPublisher(authType: AuthenticateUserAuthTypeDomainModel, authPlatform: AuthenticateUserAuthPlatformDomainModel, authPolicy: AuthenticateUserAuthPolicyDomainModel) -> AnyPublisher<AuthUserDomainModel?, AuthErrorDomainModel> {
        
        return authenticateByAuthTypePublisher(
            authType: authType,
            authPlatform: authPlatform,
            authPolicy: authPolicy
        )
        .flatMap({ (authToken: MobileContentAuthTokenDataModel) -> AnyPublisher<AuthUserDomainModel?, AuthErrorDomainModel> in
                            
            return self.getAuthUserPublisher()
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
                        
            return signInPublisher(
                provider: authPlatform.toAuthenticationProviderType(),
                createUser: authType == .createAccount,
                fromViewController: fromViewController
            )
            .mapError { (apiError: MobileContentApiError) in
                return apiError.toAuthErrorDomainModel()
            }
            .eraseToAnyPublisher()
            
        case .renewAccessToken:
            
            return renewTokenPublisher()
                .mapError { (apiError: MobileContentApiError) in
                    return apiError.toAuthErrorDomainModel()
                }
                .eraseToAnyPublisher()
        }
    }
    
    func renewAuthenticationPublisher() -> AnyPublisher<AuthUserDomainModel?, AuthErrorDomainModel> {
        
        return renewTokenPublisher()
            .mapError { (apiError: MobileContentApiError) in
                return apiError.toAuthErrorDomainModel()
            }
            .flatMap({ (authToken: MobileContentAuthTokenDataModel) -> AnyPublisher<AuthUserDomainModel?, AuthErrorDomainModel> in
                                
                return self.getAuthUserPublisher()
                    .mapError { (error: Error) in
                        return .other(error: error)
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
