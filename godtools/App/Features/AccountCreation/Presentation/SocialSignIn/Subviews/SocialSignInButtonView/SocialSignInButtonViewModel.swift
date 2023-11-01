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
    let font: Font = FontLibrary.sfProTextSemibold.font(size: 16)
    let fontColor: Color
    let buttonText: String
    let iconName: String
    let iconSize: CGSize
    
    init(buttonType: SocialSignInButtonType, localizationServices: LocalizationServices) {
        
        self.buttonType = buttonType
        
        let buttonTitleLocalizedKey: String
        
        switch buttonType {
            
        case .google:
            backgroundColor = .white
            fontColor = ColorPalette.gtGrey.color
            buttonTitleLocalizedKey = MenuStringKeys.SocialSignIn.googleSignIn.rawValue
            iconName = ImageCatalog.googleIcon.name
            iconSize = CGSize(width: 18, height: 18)
            
        case .facebook:
            backgroundColor = Color.getColorWithRGB(red: 24, green: 119, blue: 242, opacity: 1)
            fontColor = .white
            buttonTitleLocalizedKey = MenuStringKeys.SocialSignIn.facebookSignIn.rawValue
            iconName = ImageCatalog.facebookIcon.name
            iconSize = CGSize(width: 24, height: 24)
            
        case .apple:
            backgroundColor = .black
            fontColor = .white
            buttonTitleLocalizedKey = MenuStringKeys.SocialSignIn.appleSignIn.rawValue
            iconName = ImageCatalog.appleIcon.name
            iconSize = CGSize(width: 24, height: 24)
        }
        
        buttonText = localizationServices.stringForSystemElseEnglish(key: buttonTitleLocalizedKey)
    }
}
