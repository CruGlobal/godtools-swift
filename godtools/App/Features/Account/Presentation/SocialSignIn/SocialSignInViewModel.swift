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
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (appLanguage: AppLanguageDomainModel) in

                self?.appLanguage = appLanguage
                self?.didSetAppLanguage(appLanguage: appLanguage)
            })
            .store(in: &cancellables)
    }

    deinit {
        print("x deinit: \(type(of: self))")
    }

    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        switch authenticationType {
        case .createAccount:

            let strings = getSocialCreateAccountStringsUseCase
                .execute(appLanguage: appLanguage)

            title = strings.title
            subtitle = strings.subtitle
            signInWithAppleButtonTitle = strings.createWithAppleActionTitle
            signInWithFacebookButtonTitle = strings.createWithFacebookActionTitle
            signInWithGoogleButtonTitle = strings.createWithGoogleActionTitle

        case .login:

            let strings = getSocialSignInStringsUseCase
                .execute(appLanguage: appLanguage)

            title = strings.title
            subtitle = strings.subtitle
            signInWithAppleButtonTitle = strings.signInWithAppleActionTitle
            signInWithFacebookButtonTitle = strings.signInWithFacebookActionTitle
            signInWithGoogleButtonTitle = strings.signInWithGoogleActionTitle
        }
    }

    private func authenticateUser(authPlatform: AuthenticateUserAuthPlatformDomainModel) {
                
        Task {
            
            do {
                _ = try await authenticateUserUseCase
                    .execute(
                        authType: authenticationType == .createAccount ? .createAccount : .signIn,
                        authPlatform: authPlatform,
                        authPolicy: .renewAccessTokenElseAskUserToAuthenticate(fromViewController: presentAuthViewController)
                    )
                
                handleAuthenticationCompleted(error: nil)
            }
            catch let error {
                
                handleAuthenticationCompleted(error: error as? AuthErrorDomainModel)
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
