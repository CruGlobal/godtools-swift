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
    let iconSize: CGSize
    
    init(buttonType: SocialSignInButtonType, localizationServices: LocalizationServices) {
        
        self.buttonType = buttonType
        
        switch buttonType {
            
        case .google:
            backgroundColor = .white
            font = FontLibrary.robotoMedium.font(size: 16)
            fontColor = ColorPalette.gtGrey.color
            buttonText = localizationServices.stringForMainBundle(key: MenuStringKeys.SocialSignIn.googleSignIn.rawValue)
            iconName = ImageCatalog.googleIcon.name
            iconSize = CGSize(width: 18, height: 18)
            
        case .facebook:
            backgroundColor = Color.getColorWithRGB(red: 24, green: 119, blue: 242, opacity: 1)
            font = Font.system(size: 16, weight: .semibold)
            fontColor = .white
            buttonText = localizationServices.stringForMainBundle(key: MenuStringKeys.SocialSignIn.facebookSignIn.rawValue)
            iconName = ImageCatalog.facebookIcon.name
            iconSize = CGSize(width: 24, height: 24)
            
        case .apple:
            backgroundColor = .black
            font = Font.system(size: 16, weight: .semibold)
            fontColor = .white
            buttonText = localizationServices.stringForMainBundle(key: MenuStringKeys.SocialSignIn.appleSignIn.rawValue)
            iconName = ImageCatalog.appleIcon.name
            iconSize = CGSize(width: 24, height: 24)
        }
    }
    
    func loginTapped() {
        // TODO
    }
}
