//
//  GoogleAuthentication+AuthenticationProviderInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit
import SocialAuthentication
import Combine
import GoogleSignIn

extension GoogleAuthentication: AuthenticationProviderInterface {
    
    private func getResponseForPersistedData() throws -> AuthenticationProviderResponse {
        
        guard let user = getCurrentUser(), let idToken = user.idToken?.tokenString else {
            
            let error: Error = NSError.errorWithDescription(description: "Data not persisted.")
            
            throw error
        }
        
        let response = AuthenticationProviderResponse(
            accessToken: user.accessToken.tokenString,
            appleSignInAuthorizationCode: nil,
            idToken: idToken,
            oidcToken: nil,
            profile: AuthenticationProviderProfile(
                email: user.profile?.email,
                familyName: user.profile?.familyName,
                givenName: user.profile?.givenName,
                name: user.profile?.name
            ),
            providerType: .google,
            refreshToken: user.refreshToken.tokenString
        )
        
        return response
    }
    
    /*
     
    // TODO: Need to test this implementation more.  For some reason GoogleSignIn is redirecting to Safari when using GoogleSignIn SDK sign in presenting async throws. ~Levi
     
    @MainActor func providerAuthenticate(presentingViewController: UIViewController) async throws -> AuthenticationProviderResponse {
        
        let googleResponse: GoogleAuthenticationResponse = try await authenticate(from: presentingViewController)
        
        if googleResponse.isCancelled {
            throw NSError.userCancelledError()
        }
        
        return try getResponseForPersistedData()
    }*/
    
    @MainActor func providerAuthenticate(presentingViewController: UIViewController) async throws -> AuthenticationProviderResponse {
        
        return try await withCheckedThrowingContinuation { continuation in
            authenticateWithCompletion(from: presentingViewController) { result in
                switch result {
                case .success( _):
                    do {
                        let response = try self.getResponseForPersistedData()
                        continuation.resume(returning: response)
                    }
                    catch let error {
                        continuation.resume(throwing: error)
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    @MainActor private func authenticateWithCompletion(from viewController: UIViewController, completion: @escaping ((_ result: Result<GoogleAuthenticationResponse, Error>) -> Void)) {
            
        let authenticateFromViewController: UIViewController = viewController.getTopMostPresentedViewController() ?? viewController
        
        GIDSignIn.sharedInstance.signIn(withPresenting: authenticateFromViewController, hint: nil, additionalScopes: nil, completion: { [weak self] (result: GIDSignInResult?, signInError: Error?) in
            
            if let signInError = signInError {
                
                let googleSignInErrorCode: Int = (signInError as NSError).code
                                
                if googleSignInErrorCode == GIDSignInError.canceled.rawValue {
                    completion(.success(GoogleAuthenticationResponse(idToken: nil, isCancelled: true)))
                }
                else {
                    completion(.failure(signInError))
                }
            }
            else if let authenticatedUser = result?.user {
                
                self?.refreshUserTokens(user: authenticatedUser, completion: { (refreshTokenResult: Result<GoogleAuthenticationResponse, Error>) in
                    
                    switch refreshTokenResult {
                        
                    case .success(let response):
                        completion(.success(response))
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
            }
            else {
                
                let response = GoogleAuthenticationResponse.emptyResponse()
                completion(.success(response))
            }
        })
    }
    
    private func refreshUserTokens(user: GIDGoogleUser, completion: @escaping ((_ result: Result<GoogleAuthenticationResponse, Error>) -> Void)) {
            
            user.refreshTokensIfNeeded(completion: { (user: GIDGoogleUser?, error: Error?) in
                
                if let error = error {
                    
                    completion(.failure(error))
                }
                else if let user = user {
                    
                    let response = GoogleAuthenticationResponse.fromGoogleSignInUser(user: user)
                    completion(.success(response))
                }
                else {
                    
                    let response = GoogleAuthenticationResponse.emptyResponse()
                    completion(.success(response))
                }
            })
        }

    func providerRenewToken() async throws -> AuthenticationProviderResponse {
        
        _ = try await restorePreviousSignIn()
        
        return try getResponseForPersistedData()
    }
    
    func providerSignOut() {
        
        signOut()
    }
    
    func providerGetAuthUser() async throws -> AuthUserDomainModel? {
        
        let profile: GIDProfileData? = getCurrentUserProfile()
        
        return profile?.toAuthUserDomainModel()
    }
}
