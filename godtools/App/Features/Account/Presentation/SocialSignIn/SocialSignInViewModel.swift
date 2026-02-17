//
//  SocialSignInViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine

@MainActor class SocialSignInViewModel: ObservableObject {
    
    private let presentAuthViewController: UIViewController
    private let authenticationType: SocialSignInAuthenticationType
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getSocialCreateAccountStringsUseCase: GetSocialCreateAccountStringsUseCase
    private let getSocialSignInStringsUseCase: GetSocialSignInStringsUseCase
    private let authenticateUserUseCase: AuthenticateUserUseCase
    
    private var authenticateUserTask: Task<Void, Error>?
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: String = LanguageCodeDomainModel.english.value
    
    @Published var title: String = ""
    @Published var subtitle: String = ""
    @Published var signInWithAppleButtonTitle: String = ""
    @Published var signInWithFacebookButtonTitle: String = ""
    @Published var signInWithGoogleButtonTitle: String = ""
    
    init(flowDelegate: FlowDelegate, presentAuthViewController: UIViewController, authenticationType: SocialSignInAuthenticationType, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getSocialCreateAccountStringsUseCase: GetSocialCreateAccountStringsUseCase, getSocialSignInStringsUseCase: GetSocialSignInStringsUseCase, authenticateUserUseCase: AuthenticateUserUseCase) {
        
        self.flowDelegate = flowDelegate
        self.presentAuthViewController = presentAuthViewController
        self.authenticationType = authenticationType
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getSocialCreateAccountStringsUseCase = getSocialCreateAccountStringsUseCase
        self.getSocialSignInStringsUseCase = getSocialSignInStringsUseCase
        self.authenticateUserUseCase = authenticateUserUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        switch authenticationType {
        case .createAccount:
            
            $appLanguage
                .dropFirst()
                .map { (appLanguage: AppLanguageDomainModel) in
                    return getSocialCreateAccountStringsUseCase
                        .execute(appLanguage: appLanguage)
                }
                .switchToLatest()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (interfaceStrings: SocialCreateAccountStringsDomainModel) in
                    
                    self?.title = interfaceStrings.title
                    self?.subtitle = interfaceStrings.subtitle
                    self?.signInWithAppleButtonTitle = interfaceStrings.createWithAppleActionTitle
                    self?.signInWithFacebookButtonTitle = interfaceStrings.createWithFacebookActionTitle
                    self?.signInWithGoogleButtonTitle = interfaceStrings.createWithGoogleActionTitle
                }
                .store(in: &cancellables)
        
        case .login:
            
            $appLanguage
                .dropFirst()
                .map { (appLanguage: AppLanguageDomainModel) in
                    return getSocialSignInStringsUseCase
                        .execute(appLanguage: appLanguage)
                }
                .switchToLatest()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (interfaceStrings: SocialSignInStringsDomainModel) in
                    
                    self?.title = interfaceStrings.title
                    self?.subtitle = interfaceStrings.subtitle
                    self?.signInWithAppleButtonTitle = interfaceStrings.signInWithAppleActionTitle
                    self?.signInWithFacebookButtonTitle = interfaceStrings.signInWithFacebookActionTitle
                    self?.signInWithGoogleButtonTitle = interfaceStrings.signInWithGoogleActionTitle
                }
                .store(in: &cancellables)
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func authenticateUser(authPlatform: AuthenticateUserAuthPlatformDomainModel) {
                
        authenticateUserTask = Task {
            
            do {
                _ = try await authenticateUserUseCase
                    .execute(
                        authType: authenticationType == .createAccount ? .createAccount : .signIn,
                        authPlatform: authPlatform,
                        authPolicy: .renewAccessTokenElseAskUserToAuthenticate(fromViewController: presentAuthViewController)
                    )
            }
            catch let error {
                print("\n Auth error: \(error)")
            }
        }
        
//        authenticateUserUseCase
//            .execute(
//                authType: authenticationType == .createAccount ? .createAccount : .signIn,
//                authPlatform: authPlatform,
//                authPolicy: .renewAccessTokenElseAskUserToAuthenticate(fromViewController: presentAuthViewController)
//            )
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] subscriberCompletion in
//                
//                let authenticationError: AuthErrorDomainModel?
//                
//                switch subscriberCompletion {
//                case .finished:
//                    authenticationError = nil
//                case .failure(let error):
//                    // TODO: Fix auth error. ~Levi
//                    //authenticationError = error
//                    authenticationError = nil
//                }
//                
//                self?.handleAuthenticationCompleted(error: authenticationError)
//                
//            } receiveValue: { _ in
//                
//            }
//            .store(in: &cancellables)
    }
    
    private func handleAuthenticationCompleted(error: AuthErrorDomainModel?) {
                
        switch authenticationType {
        
        case .createAccount:
            flowDelegate?.navigate(step: .userCompletedSignInFromCreateAccount(error: error))
        
        case .login:
            flowDelegate?.navigate(step: .userCompletedSignInFromLogin(error: error))
        }
    }
}

// MARK: - Inputs

extension SocialSignInViewModel {
    
    @objc func closeTapped() {
        
        switch authenticationType {
        case .createAccount:
            flowDelegate?.navigate(step: .closeTappedFromCreateAccount)
            
        case .login:
            flowDelegate?.navigate(step: .closeTappedFromLogin)
        }
    }
    
    func signInWithGoogleTapped() {
        authenticateUser(authPlatform: .google)
    }
    
    func signInWithFacebookTapped() {
        authenticateUser(authPlatform: .facebook)
    }
    
    func signInWithAppleTapped() {
        authenticateUser(authPlatform: .apple)
    }
}
