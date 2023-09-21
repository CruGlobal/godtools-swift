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
    private let authenticateUserUseCase: AuthenticateUserUseCase
    private let localizationServices: LocalizationServices
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    private weak var flowDelegate: FlowDelegate?
    
    let titleText: String
    let subtitleText: String
    
    lazy var googleSignInButtonViewModel: SocialSignInButtonViewModel = {
        SocialSignInButtonViewModel(
            buttonType: .google,
            localizationServices: localizationServices
        )
    }()
    
    lazy var facebookSignInButtonViewModel: SocialSignInButtonViewModel = {
        SocialSignInButtonViewModel(
            buttonType: .facebook,
            localizationServices: localizationServices
        )
    }()
    
    lazy var appleSignInButtonViewModel: SocialSignInButtonViewModel = {
        SocialSignInButtonViewModel(
            buttonType: .apple,
            localizationServices: localizationServices
        )
    }()
    
    init(flowDelegate: FlowDelegate, presentAuthViewController: UIViewController, authenticationType: SocialSignInAuthenticationType, authenticateUserUseCase: AuthenticateUserUseCase, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.presentAuthViewController = presentAuthViewController
        self.authenticationType = authenticationType
        self.authenticateUserUseCase = authenticateUserUseCase
        self.localizationServices = localizationServices
        
        switch authenticationType {
        case .createAccount:
            titleText = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.SocialSignIn.createAccountTitle.rawValue)
            subtitleText = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.SocialSignIn.createAccountSubtitle.rawValue)
        
        case .login:
            titleText = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.SocialSignIn.signInTitle.rawValue)
            subtitleText = localizationServices.stringForSystemElseEnglish(key: MenuStringKeys.SocialSignIn.signInSubtitle.rawValue)
        }
    }
    
    private func authenticateUser(authPlatform: AuthenticateUserAuthPlatform) {
                
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
