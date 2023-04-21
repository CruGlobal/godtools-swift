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
    let font: Font
    let fontColor: Color
    let buttonText: String
    let iconName: String
    
    init(buttonType: SocialSignInButtonType) {
        
        self.buttonType = buttonType
        
        switch buttonType {
            
        case .google:
            backgroundColor = .white
            font = FontLibrary.robotoMedium.font(size: 16)
            fontColor = .gray
            buttonText = "Sign in with Google"
            iconName = ImageCatalog.googleIcon.name
            
        case .facebook:
            backgroundColor = .blue
            font = Font.system(size: 16, weight: .semibold)
            fontColor = .white
            buttonText = "Login with Facebook"
            iconName = ImageCatalog.facebookIcon.name
            
        case .apple:
            backgroundColor = .black
            font = Font.system(size: 16, weight: .semibold)
            fontColor = .white
            buttonText = "Continue with Apple"
            iconName = ImageCatalog.appleIcon.name
        }
    }
}
