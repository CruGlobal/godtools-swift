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
    
    private let authenticationType: SocialSignInAuthenticationType
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
    
    init(flowDelegate: FlowDelegate, authenticationType: SocialSignInAuthenticationType, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.authenticationType = authenticationType
        self.localizationServices = localizationServices
        
        titleText = localizationServices.stringForMainBundle(key: MenuStringKeys.SocialSignIn.signInTitle.rawValue)
        subtitleText = localizationServices.stringForMainBundle(key: MenuStringKeys.SocialSignIn.subtitle.rawValue)
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
        
        switch authenticationType {
        case .createAccount:
            flowDelegate?.navigate(step: .createAccountWithGoogleTapped)
            
        case .login:
            flowDelegate?.navigate(step: .loginWithGoogleTapped)
        }
    }
    
    func signInWithFacebookTapped() {
        
        switch authenticationType {
        case .createAccount:
            flowDelegate?.navigate(step: .createAccountWithFacebookTapped)
            
        case .login:
            flowDelegate?.navigate(step: .loginWithFacebookTapped)
        }
    }
    
    func signInWithAppleTapped() {
        
        switch authenticationType {
        case .createAccount:
            flowDelegate?.navigate(step: .createAccountWithAppleTapped)
            
        case .login:
            flowDelegate?.navigate(step: .loginWithAppleTapped)
        }
    }
}
