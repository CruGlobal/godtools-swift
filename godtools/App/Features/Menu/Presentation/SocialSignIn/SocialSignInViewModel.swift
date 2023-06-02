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
    private let authenticationCompletedSubject: PassthroughSubject<Void, Never>
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
    
    init(flowDelegate: FlowDelegate, presentAuthViewController: UIViewController, authenticationType: SocialSignInAuthenticationType, authenticationCompletedSubject: PassthroughSubject<Void, Never>, authenticateUserUseCase: AuthenticateUserUseCase, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.presentAuthViewController = presentAuthViewController
        self.authenticationType = authenticationType
        self.authenticationCompletedSubject = authenticationCompletedSubject
        self.authenticateUserUseCase = authenticateUserUseCase
        self.localizationServices = localizationServices
        
        titleText = localizationServices.stringForMainBundle(key: MenuStringKeys.SocialSignIn.signInTitle.rawValue)
        subtitleText = localizationServices.stringForMainBundle(key: MenuStringKeys.SocialSignIn.subtitle.rawValue)
    }
    
    private func authenticateUser(provider: AuthenticationProviderType) {
        
        authenticateUserUseCase.authenticatePublisher(
            provider: provider,
            policy: .renewAccessTokenElseAskUserToAuthenticate(fromViewController: presentAuthViewController),
            createUser: authenticationType == .createAccount
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] subscriberCompletion in
            
            let authenticationError: Error?
            
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
    
    private func handleAuthenticationCompleted(error: Error?) {
        
        authenticationCompletedSubject.send(())
        
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
        authenticateUser(provider: .google)
    }
    
    func signInWithFacebookTapped() {
        authenticateUser(provider: .facebook)
    }
    
    func signInWithAppleTapped() {
        authenticateUser(provider: .apple)
    }
}
