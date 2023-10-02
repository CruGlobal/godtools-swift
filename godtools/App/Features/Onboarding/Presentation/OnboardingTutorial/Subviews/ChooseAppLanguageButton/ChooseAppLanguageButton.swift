//
//  ChooseAppLanguageButton.swift
//  godtools
//
//  Created by Levi Eggert on 9/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct ChooseAppLanguageButton: View {

    private let backgroundColor: Color = Color.getColorWithRGB(red: 238, green: 236, blue: 238, opacity: 1)
    private let cornerRadius: CGFloat = 25
    private let width: CGFloat = 175
    private let height: CGFloat = 50
    private let title: String
    private let titleColor: Color = ColorPalette.gtGrey.color
    private let titleFont: Font = FontLibrary.sfProTextRegular.font(size: 16)
    private let tappedClosure: (() -> Void)?
    
    init(title: String, tappedClosure: (() -> Void)?) {
        
        self.title = title
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        Button(action: {
            tappedClosure?()
        }) {
            
            HStack(alignment: .center, spacing: 0) {
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 18, height: 1)
                
                ImageCatalog.languageSettingsLogo.image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 22, height: 22)
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 11, height: 1)
                
                Text(title)
                    .font(titleFont)
                    .foregroundColor(titleColor)
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 23, height: 1)
            }
        }
        .frame(minWidth: 175)
        .frame(height: height, alignment: .center)
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
    }
}

struct ChooseAppLanguageButton_Preview: PreviewProvider {
    
    static var previews: some View {
        
        ChooseAppLanguageButton(title: "Choose App Language", tappedClosure: nil)
    }
}
