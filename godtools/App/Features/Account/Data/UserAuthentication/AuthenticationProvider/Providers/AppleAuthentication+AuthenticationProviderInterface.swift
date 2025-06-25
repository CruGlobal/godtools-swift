//
//  AppleAuthentication+AuthenticationProviderInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 5/16/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit
import SocialAuthentication
import Combine

extension AppleAuthentication: AuthenticationProviderInterface {
    
    private func getAuthenticationProviderResponse(appleAuthResponse: AppleAuthenticationResponse) -> Result<AuthenticationProviderResponse, Error> {
        
        guard let authCode = appleAuthResponse.authorizationCode else {
            return .failure(NSError.errorWithDescription(description: "Failed to get authorization code."))
        }
        
        let name: String?
        
        if #available(iOS 15.0, *) {
            name = appleAuthResponse.fullName?.formatted()
        }
        else {
            name = nil
        }
        
        let response = AuthenticationProviderResponse(
            accessToken: nil,
            appleSignInAuthorizationCode: authCode,
            idToken: appleAuthResponse.identityToken,
            oidcToken: nil,
            profile: AuthenticationProviderProfile(
                email: appleAuthResponse.email,
                familyName: appleAuthResponse.fullName?.familyName,
                givenName: appleAuthResponse.fullName?.givenName,
                name: name
            ),
            providerType: .apple,
            refreshToken: nil
        )
        
        return .success(response)
    }
    
    func authenticatePublisher(presentingViewController: UIViewController) -> AnyPublisher<AuthenticationProviderResponse, Error> {
        
        return authenticatePublisher()
            .flatMap({ (response: AppleAuthenticationResponse) -> AnyPublisher<AuthenticationProviderResponse, Error> in
                
                if response.isCancelled {
                    return Fail(error: NSError.userCancelledError())
                        .eraseToAnyPublisher()
                }

                return self.getAuthenticationProviderResponse(appleAuthResponse: response).publisher
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func renewTokenPublisher() -> AnyPublisher<AuthenticationProviderResponse, Error> {
        
        // Apple token renewal is handled in UserAuthentication since Apple token renewal occurs through Mobile-Content-Api.
        let error: Error = NSError.errorWithDescription(description: "Access token renewal is handled in UserAuthentication.swift-- this method shouldn't be called.")

        return Fail(error: error)
            .eraseToAnyPublisher()
    }
    
    func signOutPublisher() -> AnyPublisher<Void, Error> {
        
        signOut()
        
        return Just(()).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getAuthUserPublisher() -> AnyPublisher<AuthUserDomainModel?, Error> {
                
        let profile = getCurrentUserProfile()
        
        return Just(mapProfileToAuthUser(profile: profile))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func mapProfileToAuthUser(profile: AppleUserProfile) -> AuthUserDomainModel {
        
        return AuthUserDomainModel(
            email: profile.email ?? "",
            firstName: profile.givenName,
            grMasterPersonId: nil,
            lastName: profile.familyName,
            name: nil,
            ssoGuid: nil
        )
    }
}
