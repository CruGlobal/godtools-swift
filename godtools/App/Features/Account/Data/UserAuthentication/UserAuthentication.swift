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

final class UserAuthentication {
        
    private let authenticationProviders: [AuthenticationProviderType: AuthenticationProviderInterface]
    private let lastAuthenticatedProviderCache: LastAuthenticatedProviderCache
    private let mobileContentAuthTokenRepository: MobileContentAuthTokenRepository
    
    init(authenticationProviders: [AuthenticationProviderType: AuthenticationProviderInterface], lastAuthenticatedProviderCache: LastAuthenticatedProviderCache, mobileContentAuthTokenRepository: MobileContentAuthTokenRepository) {
                
        self.authenticationProviders = authenticationProviders
        self.lastAuthenticatedProviderCache = lastAuthenticatedProviderCache
        self.mobileContentAuthTokenRepository = mobileContentAuthTokenRepository
    }
    
    var isAuthenticated: Bool {
        
        guard let authTokenData = mobileContentAuthTokenRepository.getCachedAuthTokenModel() else {
            return false
        }
        
        return !authTokenData.isExpired
    }
    
    func getIsAuthenticatedChangedPublisher() -> AnyPublisher<Bool, Never> {
        
        return mobileContentAuthTokenRepository.getAuthTokenChangedPublisher()
            .map { (authToken: MobileContentAuthTokenDataModel?) in
                
                guard let authToken = authToken else {
                    return false
                }
                
                return !authToken.isExpired
            }
            .eraseToAnyPublisher()
    }
    
    private func getLastAuthenticatedProvider() -> AuthenticationProviderInterface? {
        
        guard let lastAuthenticatedProvider = lastAuthenticatedProviderCache.getLastAuthenticatedProvider() else {
            return nil
        }
        
        return authenticationProviders[lastAuthenticatedProvider]
    }
    
    private func getAuthenticationProvider(provider: AuthenticationProviderType) throws -> AuthenticationProviderInterface {
        
        guard let provider = authenticationProviders[provider] else {
            let error: Error = NSError.errorWithDescription(description: "Missing authentication provider: \(provider)")
            throw error
        }
        
        return provider
    }
    
    func getLastAuthenticatedProviderType() -> AuthenticationProviderType? {
        return lastAuthenticatedProviderCache.getLastAuthenticatedProvider()
    }
    
    func renewToken() async throws -> Result<MobileContentAuthTokenDataModel, MobileContentApiError> {
        
        guard let lastAuthenticatedProviderType = getLastAuthenticatedProviderType() else {
            let error: Error = NSError.errorWithDescription(description: "Last authenticated provider does not exist.")
            throw error
        }
        
        let provider: AuthenticationProviderInterface = try getAuthenticationProvider(
            provider: lastAuthenticatedProviderType
        )
        
        let response: AuthenticationProviderResponse
        
        if let appleProvider = provider as? AppleAuthentication  {
            
            response = try await renewAppleToken(appleProvider: appleProvider)
            
        } else {
            
            response = try await provider.providerRenewToken()
        }
        
        let providerToken: MobileContentAuthProviderToken = try getMobileContentAuthProviderToken(
            authProviderResponse: response
        )
        
        let result: Result<MobileContentAuthTokenDataModel, MobileContentApiError> = try await mobileContentAuthTokenRepository.fetchRemoteAuthToken(
            providerToken: providerToken,
            createUser: false
        )
        
        return result
    }
    
    func getAuthUser() async throws -> AuthUserDomainModel? {
        
        guard let lastAuthProvider = getLastAuthenticatedProvider() else {
            return nil
        }
        
        return try await lastAuthProvider.providerGetAuthUser()
    }
    
    @MainActor func signIn(provider: AuthenticationProviderType, createUser: Bool, fromViewController: UIViewController) async throws -> Result<MobileContentAuthTokenDataModel, MobileContentApiError> {
        
        let authProvider: AuthenticationProviderInterface = try getAuthenticationProvider(provider: provider)
        
        let response: AuthenticationProviderResponse = try await authProvider.providerAuthenticate(presentingViewController: fromViewController)
        
        lastAuthenticatedProviderCache.store(provider: provider)
        
        let token: MobileContentAuthProviderToken = try getMobileContentAuthProviderToken(authProviderResponse: response)
        
        return try await mobileContentAuthTokenRepository.fetchRemoteAuthToken(providerToken: token, createUser: createUser)
    }
    
    func signOut() {
        
        let allProviders: [AuthenticationProviderInterface] = Array(authenticationProviders.values)
        
        for provider in allProviders {
            provider.providerSignOut()
        }
    }

    private func renewAppleToken(appleProvider: AppleAuthentication) async throws -> AuthenticationProviderResponse {
        
        let authUserDomainModel: AuthUserDomainModel? = try await appleProvider.providerGetAuthUser()
        
        let authProviderProfile = AuthenticationProviderProfile(
            email: authUserDomainModel?.email,
            familyName: authUserDomainModel?.lastName,
            givenName: authUserDomainModel?.firstName,
            name: authUserDomainModel?.name
        )
        
        let persistedAppleRefreshToken = self.mobileContentAuthTokenRepository.getCachedAuthTokenModel()?.appleRefreshToken
        
        let appleAuthProviderResponse = AuthenticationProviderResponse(
            accessToken: nil,
            appleSignInAuthorizationCode: nil,
            idToken: nil,
            oidcToken: nil,
            profile: authProviderProfile,
            providerType: .apple,
            refreshToken: persistedAppleRefreshToken
        )
        
        return appleAuthProviderResponse
    }
    
    private func getMobileContentAuthProviderToken(authProviderResponse: AuthenticationProviderResponse) throws -> MobileContentAuthProviderToken {
        
        switch authProviderResponse.providerType {
            
        case .apple:
            
            if let authCode = authProviderResponse.appleSignInAuthorizationCode, authCode.isEmpty == false {
                
                let profile = authProviderResponse.profile
                
                return .appleAuth(authCode: authCode, givenName: profile.givenName, familyName: profile.familyName, name: profile.name)
                
            } else if let refreshToken = authProviderResponse.refreshToken, refreshToken.isEmpty == false {
                
                return .appleRefresh(refreshToken: refreshToken)
                
            } else {
                
                throw NSError.errorWithDescription(description: "Missing apple auth code or refresh token")
            }
                        
        case .facebook:
            
            if let oidcToken = authProviderResponse.oidcToken, !oidcToken.isEmpty {
                return .facebookLimitedLogin(oidcToken: oidcToken)
            }
            
            throw NSError.errorWithDescription(description: "Missing facebook oidcToken.")
            
        case .google:
            
            guard let idToken = authProviderResponse.idToken, !idToken.isEmpty else {
                throw NSError.errorWithDescription(description: "Missing google idToken.")
            }
            
            return .google(idToken: idToken)
        }
    }
}
