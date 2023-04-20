//
//  SocialSignInButtonViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import SwiftUI

enum SocialSignInButtonType {
    case google
    case facebook
    case apple
}

class SocialSignInButtonViewModel: ObservableObject {
    
    private let buttonType: SocialSignInButtonType
    
    let backgroundColor: Color
    let fontColor: Color
    let buttonText: String
    let iconName: String
    
    init(buttonType: SocialSignInButtonType) {
        
        self.buttonType = buttonType
        
        switch buttonType {
            
        case .google:
            backgroundColor = .white
            fontColor = .gray
            buttonText = "Sign in with Google"
            iconName = ImageCatalog.googleIcon.name
            
        case .facebook:
            backgroundColor = .blue
            fontColor = .white
            buttonText = "Login with Facebook"
            iconName = ImageCatalog.facebookIcon.name
            
        case .apple:
            backgroundColor = .black
            fontColor = .white
            buttonText = "Continue with Google"
            iconName = ImageCatalog.appleIcon.name
        }
    }
}
