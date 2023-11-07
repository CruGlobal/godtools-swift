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

class SocialSignInViewModel: ObservableObject {
    
    private let presentAuthViewController: UIViewController
    private let authenticationType: SocialSignInAuthenticationType
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getSocialCreateAccountInterfaceStringsUseCase: GetSocialCreateAccountInterfaceStringsUseCase
    private let getSocialSignInInterfaceStringsUseCase: GetSocialSignInInterfaceStringsUseCase
    private let authenticateUserUseCase: AuthenticateUserUseCase
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: String = LanguageCodeDomainModel.english.value
    
    @Published var title: String = ""
    @Published var subtitle: String = ""
    @Published var signInWithAppleButtonTitle: String = ""
    @Published var signInWithFacebookButtonTitle: String = ""
    @Published var signInWithGoogleButtonTitle: String = ""
    
    init(flowDelegate: FlowDelegate, presentAuthViewController: UIViewController, authenticationType: SocialSignInAuthenticationType, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, getSocialCreateAccountInterfaceStringsUseCase: GetSocialCreateAccountInterfaceStringsUseCase, getSocialSignInInterfaceStringsUseCase: GetSocialSignInInterfaceStringsUseCase, authenticateUserUseCase: AuthenticateUserUseCase) {
        
        self.flowDelegate = flowDelegate
        self.presentAuthViewController = presentAuthViewController
        self.authenticationType = authenticationType
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getSocialCreateAccountInterfaceStringsUseCase = getSocialCreateAccountInterfaceStringsUseCase
        self.getSocialSignInInterfaceStringsUseCase = getSocialSignInInterfaceStringsUseCase
        self.authenticateUserUseCase = authenticateUserUseCase
        
        getCurrentAppLanguageUseCase
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        switch authenticationType {
        case .createAccount:
            
            getSocialCreateAccountInterfaceStringsUseCase
                .getStringsPublisher(appLanguageChangedPublisher: $appLanguage.eraseToAnyPublisher())
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (interfaceStrings: SocialCreateAccountInterfaceStringsDomainModel) in
                    
                    self?.title = interfaceStrings.title
                    self?.subtitle = interfaceStrings.subtitle
                    self?.signInWithAppleButtonTitle = interfaceStrings.createWithAppleActionTitle
                    self?.signInWithFacebookButtonTitle = interfaceStrings.createWithFacebookActionTitle
                    self?.signInWithGoogleButtonTitle = interfaceStrings.createWithGoogleActionTitle
                }
                .store(in: &cancellables)
        
        case .login:
            
            getSocialSignInInterfaceStringsUseCase
                .getStringsPublisher(appLanguageChangedPublisher: $appLanguage.eraseToAnyPublisher())
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (interfaceStrings: SocialSignInInterfaceStringsDomainModel) in
                    
                    self?.title = interfaceStrings.title
                    self?.subtitle = interfaceStrings.subtitle
                    self?.signInWithAppleButtonTitle = interfaceStrings.signInWithAppleActionTitle
                    self?.signInWithFacebookButtonTitle = interfaceStrings.signInWithFacebookActionTitle
                    self?.signInWithGoogleButtonTitle = interfaceStrings.signInWithGoogleActionTitle
                }
                .store(in: &cancellables)
        }
    }
    
    private func authenticateUser(authPlatform: AuthenticateUserAuthPlatformDomainModel) {
                
        authenticateUserUseCase.authenticatePublisher(
            authType: authenticationType == .createAccount ? .createAccount : .signIn,
            authPlatform: authPlatform,
            authPolicy: .renewAccessTokenElseAskUserToAuthenticate(fromViewController: presentAuthViewController)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] subscriberCompletion in
            
            let authenticationError: AuthErrorDomainModel?
            
            switch subscriberCompletion {
            case .finished:
                authenticationError = nil
            case .failure(let error):
                authenticationError = error
            }
            
            self?.handleAuthenticationCompleted(error: authenticationError)
            
        } receiveValue: { _ in
            
        }
        .store(in: &cancellables)
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
