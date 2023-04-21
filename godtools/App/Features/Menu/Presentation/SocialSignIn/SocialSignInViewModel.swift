//
//  SocialSignInViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class SocialSignInViewModel: ObservableObject {
    
    private let localizationServices: LocalizationServices
    
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
    
    init(localizationServices: LocalizationServices) {
        
        self.localizationServices = localizationServices
        
        titleText = localizationServices.stringForMainBundle(key: MenuStringKeys.SocialSignIn.signInTitle.rawValue)
        subtitleText = localizationServices.stringForMainBundle(key: MenuStringKeys.SocialSignIn.subtitle.rawValue)
    }
}
