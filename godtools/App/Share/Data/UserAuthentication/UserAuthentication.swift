//
//  UserAuthentication.swift
//  godtools
//
//  Created by Rachael Skeath on 11/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit
import Combine
import SocialAuthentication

class UserAuthentication {
        
    private let authenticationProviders: [AuthenticationProviderType: AuthenticationProviderInterface]
    private let lastAuthenticatedProviderCache: LastAuthenticatedProviderCache
    
    init(authenticationProviders: [AuthenticationProviderType: AuthenticationProviderInterface], lastAuthenticatedProviderCache: LastAuthenticatedProviderCache) {
                
        self.authenticationProviders = authenticationProviders
        self.lastAuthenticatedProviderCache = lastAuthenticatedProviderCache
    }
    
    private func getLastAuthenticatedProvider() -> AuthenticationProviderInterface? {
        
        guard let lastAuthenticatedProvider = lastAuthenticatedProviderCache.getLastAuthenticatedProvider() else {
            return nil
        }
        
        return authenticationProviders[lastAuthenticatedProvider]
    }
    
    private func getAuthenticationProvider(provider: AuthenticationProviderType) -> AnyPublisher<AuthenticationProviderInterface, Error> {
        
        guard let provider = authenticationProviders[provider] else {
            return Fail(error: NSError.errorWithDescription(description: "Missing authentication provider: \(provider)"))
                .eraseToAnyPublisher()
        }
        
        return Just(provider).setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getLastAuthenticatedProviderType() -> AuthenticationProviderType? {
        return lastAuthenticatedProviderCache.getLastAuthenticatedProvider()
    }
    
    func getPersistedAccessToken() -> String? {
        return getLastAuthenticatedProvider()?.getPersistedAccessToken()?.tokenString
    }
    
    func renewAccessTokenPublisher() -> AnyPublisher<AuthenticationProviderAccessToken, Error> {
        
        guard let lastAuthenticatedProvider = getLastAuthenticatedProviderType() else {
            return Fail(error: NSError.errorWithDescription(description: "Last authenticated provider does not exist."))
                .eraseToAnyPublisher()
        }
        
        return getAuthenticationProvider(provider: lastAuthenticatedProvider)
            .flatMap({ (provider: AuthenticationProviderInterface) -> AnyPublisher<AuthenticationProviderAccessToken, Error> in
                return provider.renewAccessTokenPublisher()
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func getAuthUserPublisher() -> AnyPublisher<AuthUserDomainModel?, Error> {
        
        guard let lastAuthProvider = getLastAuthenticatedProvider() else {
            return Just(nil).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return lastAuthProvider.getAuthUserPublisher()
            .eraseToAnyPublisher()
    }
    
    func signInPublisher(provider: AuthenticationProviderType, fromViewController: UIViewController) -> AnyPublisher<Void, Error> {
    
        return getAuthenticationProvider(provider: provider)
            .flatMap({ (provider: AuthenticationProviderInterface) -> AnyPublisher<AuthenticationProviderAccessToken?, Error> in
                
                return provider.authenticatePublisher(presentingViewController: fromViewController)
            })
            .map { (providerAccessToken: AuthenticationProviderAccessToken?) in
                
                if providerAccessToken != nil {
                    self.lastAuthenticatedProviderCache.store(provider: provider)
                }
                
                return ()
            }
            .eraseToAnyPublisher()
    }
    
    func signOutPublisher(fromViewController: UIViewController) -> AnyPublisher<Void, Error> {
             
        guard let lastAuthProvider = getLastAuthenticatedProvider() else {
            return Just(()).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return lastAuthProvider.signOutPublisher()
            .map { response in
                self.lastAuthenticatedProviderCache.deleteLastAuthenticatedProvider()
                return response
            }
            .eraseToAnyPublisher()
        
        // TODO: Should we sign out of all providers? ~Levi
        /*
        let allProviders: [AuthenticationProviderInterface] = Array(authenticationProviders.values)
        let signOutPublishers = allProviders.map {
            $0.signOutPublisher()
        }
        
        return Publishers.MergeMany(signOutPublishers)
            .collect()
            .eraseToAnyPublisher()*/
    }
}
