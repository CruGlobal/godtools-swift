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
    private let mobileContentAuthTokenRepository: MobileContentAuthTokenRepository
    
    init(authenticationProviders: [AuthenticationProviderType: AuthenticationProviderInterface], lastAuthenticatedProviderCache: LastAuthenticatedProviderCache, mobileContentAuthTokenRepository: MobileContentAuthTokenRepository) {
                
        self.authenticationProviders = authenticationProviders
        self.lastAuthenticatedProviderCache = lastAuthenticatedProviderCache
        self.mobileContentAuthTokenRepository = mobileContentAuthTokenRepository
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
    
    func getPersistedResponse() -> AuthenticationProviderResponse? {
        return getLastAuthenticatedProvider()?.getPersistedResponse()
    }
    
    func renewTokenPublisher() -> AnyPublisher<MobileContentAuthTokenDataModel, Error> {
        
        guard let lastAuthenticatedProvider = getLastAuthenticatedProviderType() else {
            return Fail(error: NSError.errorWithDescription(description: "Last authenticated provider does not exist."))
                .eraseToAnyPublisher()
        }
        
        return getAuthenticationProvider(provider: lastAuthenticatedProvider)
            .flatMap({ (provider: AuthenticationProviderInterface) -> AnyPublisher<AuthenticationProviderResponse, Error> in
                
                return provider.renewTokenPublisher()
                    .eraseToAnyPublisher()
            })
            .flatMap { (authProviderResponse: AuthenticationProviderResponse) -> AnyPublisher<MobileContentAuthTokenDataModel, Error> in
                
                return self.authenticateWithMobileContentApi(authProviderResponse: authProviderResponse, createUser: false)
            }
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
    
    func signInPublisher(provider: AuthenticationProviderType, createUser: Bool, fromViewController: UIViewController) -> AnyPublisher<MobileContentAuthTokenDataModel, Error> {
    
        return getAuthenticationProvider(provider: provider)
            .flatMap({ (provider: AuthenticationProviderInterface) -> AnyPublisher<AuthenticationProviderResponse, Error> in
                
                return provider.authenticatePublisher(presentingViewController: fromViewController)
            })
            .map { (response: AuthenticationProviderResponse) in
                
                self.lastAuthenticatedProviderCache.store(provider: provider)
                
                return response
            }
            .flatMap { (authProviderResponse: AuthenticationProviderResponse) -> AnyPublisher<MobileContentAuthTokenDataModel, Error> in
                
                return self.authenticateWithMobileContentApi(authProviderResponse: authProviderResponse, createUser: createUser)
            }
            .eraseToAnyPublisher()
    }
    
    func signOutPublisher() -> AnyPublisher<Void, Error> {
             
        signOutOfAllProviders()
            .map { response in
                self.lastAuthenticatedProviderCache.deleteLastAuthenticatedProvider()
                self.mobileContentAuthTokenRepository.deleteCachedAuthToken()
                
                return response
            }
            .eraseToAnyPublisher()
    }
    
    private func authenticateWithMobileContentApi(authProviderResponse: AuthenticationProviderResponse, createUser: Bool) -> AnyPublisher<MobileContentAuthTokenDataModel, Error> {
        
        return authProviderResponse.getMobileContentAuthProviderToken().publisher
            .flatMap({ (providerToken: MobileContentAuthProviderToken) -> AnyPublisher<MobileContentAuthTokenDataModel, Error> in
                
                return self.mobileContentAuthTokenRepository.fetchRemoteAuthTokenPublisher(providerToken: providerToken, createUser: createUser)
                    .mapError { urlResponseError in
                        return urlResponseError as Error
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func signOutOfAllProviders() -> AnyPublisher<Void, Error> {
        
        let allProviders: [AuthenticationProviderInterface] = Array(authenticationProviders.values)
        let signOutPublishers = allProviders.map {
            $0.signOutPublisher()
        }
        
        return Publishers.MergeMany(signOutPublishers)
            .collect()
            .map { _ in
                return ()
            }
            .eraseToAnyPublisher()
    }
}
