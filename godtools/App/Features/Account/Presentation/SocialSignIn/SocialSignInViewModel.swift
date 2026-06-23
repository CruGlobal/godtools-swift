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

@MainActor
final class SocialSignInViewModel: ObservableObject {
    
    private let stepEmitter: FlowStepEmitter
    private let presentAuthViewController: UIViewController
    private let authenticationType: SocialSignInAuthenticationType
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getSocialCreateAccountStringsUseCase: GetSocialCreateAccountStringsUseCase
    private let getSocialSignInStringsUseCase: GetSocialSignInStringsUseCase
    private let authenticateUserUseCase: AuthenticateUserUseCase
    
    private var authenticateUserTask: Task<Void, Error>?
    private var cancellables: Set<AnyCancellable> = Set()
        
    @Published private var appLanguage: String = LanguageCodeDomainModel.english.value
    
    @Published var title: String = ""
    @Published var subtitle: String = ""
    @Published var signInWithAppleButtonTitle: String = ""
    @Published var signInWithFacebookButtonTitle: String = ""
    @Published var signInWithGoogleButtonTitle: String = ""
    
    init(
        stepEmitter: FlowStepEmitter,
        presentAuthViewController: UIViewController,
        authenticationType: SocialSignInAuthenticationType,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getSocialCreateAccountStringsUseCase: GetSocialCreateAccountStringsUseCase,
        getSocialSignInStringsUseCase: GetSocialSignInStringsUseCase,
        authenticateUserUseCase: AuthenticateUserUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.presentAuthViewController = presentAuthViewController
        self.authenticationType = authenticationType
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getSocialCreateAccountStringsUseCase = getSocialCreateAccountStringsUseCase
        self.getSocialSignInStringsUseCase = getSocialSignInStringsUseCase
        self.authenticateUserUseCase = authenticateUserUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
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
                .sink { [weak self] (strings: SocialCreateAccountStringsDomainModel) in
                    
                    self?.title = strings.title
                    self?.subtitle = strings.subtitle
                    self?.signInWithAppleButtonTitle = strings.createWithAppleActionTitle
                    self?.signInWithFacebookButtonTitle = strings.createWithFacebookActionTitle
                    self?.signInWithGoogleButtonTitle = strings.createWithGoogleActionTitle
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
                .sink { [weak self] (strings: SocialSignInStringsDomainModel) in
                    
                    self?.title = strings.title
                    self?.subtitle = strings.subtitle
                    self?.signInWithAppleButtonTitle = strings.signInWithAppleActionTitle
                    self?.signInWithFacebookButtonTitle = strings.signInWithFacebookActionTitle
                    self?.signInWithGoogleButtonTitle = strings.signInWithGoogleActionTitle
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
                
                self.handleAuthenticationCompleted(error: nil)
            }
            catch let error {
                
                self.handleAuthenticationCompleted(error: error as? AuthErrorDomainModel)
            }
        }
    }
    
    private func handleAuthenticationCompleted(error: AuthErrorDomainModel?) {
                
        switch authenticationType {
        
        case .createAccount:
            stepEmitter.emit(step: AppFlowStep.userCompletedSignInFromCreateAccount(error: error))
        
        case .login:
            stepEmitter.emit(step: AppFlowStep.userCompletedSignInFromLogin(error: error))
        }
    }
}

// MARK: - Inputs

extension SocialSignInViewModel {
    
    @objc func closeTapped() {
        
        switch authenticationType {
        case .createAccount:
            stepEmitter.emit(step: AppFlowStep.closeTappedFromCreateAccount)
            
        case .login:
            stepEmitter.emit(step: AppFlowStep.closeTappedFromLogin)
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
