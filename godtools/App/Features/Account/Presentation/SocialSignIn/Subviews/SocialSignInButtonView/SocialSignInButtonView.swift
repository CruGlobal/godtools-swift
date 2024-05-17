//
//  SocialSignInButtonView.swift
//  godtools
//
//  Created by Rachael Skeath on 4/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct SocialSignInButtonView: View {
    
    private let buttonType: SocialSignInButtonType
    private let backgroundColor: Color
    private let font: Font = FontLibrary.sfProTextSemibold.font(size: 16)
    private let fontColor: Color
    private let title: String
    private let iconName: String
    private let iconSize: CGSize
    private let height: CGFloat = 43
    private let cornerRadius: CGFloat = 6
    private let tappedClosure: (() -> Void)
        
    init(buttonType: SocialSignInButtonType, title: String, tappedClosure: @escaping (() -> Void)) {
        
        self.buttonType = buttonType
        self.title = title
        self.tappedClosure = tappedClosure
        
        switch buttonType {
            
        case .google:
            backgroundColor = .white
            fontColor = ColorPalette.gtGrey.color
            iconName = ImageCatalog.googleIcon.name
            iconSize = CGSize(width: 18, height: 18)
            
        case .facebook:
            backgroundColor = Color.getColorWithRGB(red: 24, green: 119, blue: 242, opacity: 1)
            fontColor = .white
            iconName = ImageCatalog.facebookIcon.name
            iconSize = CGSize(width: 24, height: 24)
            
        case .apple:
            backgroundColor = .black
            fontColor = .white
            iconName = ImageCatalog.appleIcon.name
            iconSize = CGSize(width: 24, height: 24)
        }
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
                     
            Button {
                                
                tappedClosure()
                
            } label: {
                
                ZStack(alignment: .center) {
                
                    Rectangle()
                        .fill(.clear)
                        .frame(height: height)
                        .cornerRadius(cornerRadius)
                        .ignoresSafeArea()
                    
                    HStack(spacing: 12) {
                        
                        Image(iconName)
                            .frame(width: iconSize.width, height: iconSize.height)
                        
                        Text(title)
                            .font(font)
                            .foregroundColor(fontColor)
                    }
                }
            }
            .frame(height: height)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
        }
    }
}
