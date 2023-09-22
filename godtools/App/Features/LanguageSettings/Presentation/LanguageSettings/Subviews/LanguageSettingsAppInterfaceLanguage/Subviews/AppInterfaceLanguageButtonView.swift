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
    
    init(title: String, width: CGFloat, height: CGFloat) {
        
        self.title = title
        self.width = width
        self.height = height
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            Button(action: {

            }) {
                
                ZStack(alignment: .center) {
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: width, height: height)
                        .cornerRadius(cornerRadius)
                    
                    Text(title)
                        .font(FontLibrary.sfProTextRegular.font(size: 14))
                        .foregroundColor(ColorPalette.gtGrey.color)
                        .multilineTextAlignment(.center)
                    
                }
            }
            .frame(width: width, height: height, alignment: .center)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
        }
    }
}

