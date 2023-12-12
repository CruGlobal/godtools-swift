//
//  AppInterfaceLanguageButtonView.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import SwiftUI

struct AppInterfaceLanguageButtonView: View {
    
    private let backgroundColor: Color = Color.getColorWithRGB(red: 239, green: 239, blue: 239, opacity: 1)
    private let title: String
    private let width: CGFloat
    private let height: CGFloat
    private let cornerRadius: CGFloat = 6
    private let tappedClosure: (() -> Void)?
    
    init(title: String, width: CGFloat, height: CGFloat, tappedClosure: (() -> Void)?) {
        
        self.title = title
        self.width = width
        self.height = height
        self.tappedClosure = tappedClosure
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            Button(action: {
                tappedClosure?()
            }) {
                
                ZStack(alignment: .center) {
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: width, height: height)
                        .cornerRadius(cornerRadius)
                    
                    HStack(alignment: .center, spacing: 0) {
                        
                        ImageCatalog.languageSettingsLogo.image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 15, height: 15)
                        
                        Text(title)
                            .font(FontLibrary.sfProTextRegular.font(size: 14))
                            .foregroundColor(ColorPalette.gtGrey.color)
                            .multilineTextAlignment(.center)
                            .padding([.leading], 6)
                        
                        ImageCatalog.buttonDownArrow.image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 10, height: 5)
                            .padding([.leading], 8)
                    }
                }
            }
            .frame(width: width, height: height, alignment: .center)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
        }
    }
}

