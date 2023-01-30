//
//  GTWhiteButton.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct GTWhiteButton: View {
    
    let title: String
    let fontSize: CGFloat
    let width: CGFloat?
    let height: CGFloat?
    let cornerRadius: CGFloat
    let action: () -> Void
    
    init(title: String, fontSize: CGFloat = 12, width: CGFloat? = nil, height: CGFloat? = nil, cornerRadius: CGFloat = 6, action: @escaping () -> Void) {
        self.title = title
        self.fontSize = fontSize
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.action = action
    }
    
    var body: some View {
        
        Button(action: {
            action()
        }) {
            
            ZStack(alignment: .center) {
                
                Rectangle()
                    .fill(.clear)
                    .frame(width: width, height: height)
                    .cornerRadius(cornerRadius)
                
                Text(title)
                    .font(FontLibrary.sfProTextRegular.font(size: fontSize))
                    .foregroundColor(ColorPalette.gtBlue.color)
                    .padding()
            }
        }
        .frame(width: width, height: height, alignment: .center)
        .background(Color.white)
        .accentColor(ColorPalette.gtBlue.color)
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(ColorPalette.gtBlue.color, lineWidth: 1)
        )
    }
}

struct GTWhiteButton_Previews: PreviewProvider {
    static var previews: some View {
        GTWhiteButton(title: "Test Button", action: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
