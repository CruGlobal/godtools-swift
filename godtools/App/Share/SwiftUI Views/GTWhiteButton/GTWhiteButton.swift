//
//  GTWhiteButton.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct GTWhiteButton: View {
    
    private let accessibility: AccessibilityStrings.Button?
    
    let title: String
    let font: Font
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    let titleHorizontalPadding: CGFloat?
    let titleVerticalPadding: CGFloat?
    let action: () -> Void
    
    init(title: String, font: Font? = nil, fontSize: CGFloat? = nil, width: CGFloat, height: CGFloat, cornerRadius: CGFloat = 6, titleHorizontalPadding: CGFloat? = nil, titleVerticalPadding: CGFloat? = nil, accessibility: AccessibilityStrings.Button? = nil, action: @escaping () -> Void) {
        self.title = title
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.titleHorizontalPadding = titleHorizontalPadding
        self.titleVerticalPadding = titleVerticalPadding
        self.accessibility = accessibility
        self.action = action
        
        if let font = font {
            self.font = font
        }
        else if let fontSize = fontSize {
            self.font = GTWhiteButton.getDefaultFont(fontSize: fontSize)
        }
        else {
            self.font = GTWhiteButton.getDefaultFont(fontSize: 12)
        }
    }
    
    private static func getDefaultFont(fontSize: CGFloat) -> Font {
        return FontLibrary.sfProTextRegular.font(size: fontSize)
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
                    .font(font)
                    .foregroundColor(ColorPalette.gtBlue.color)
                    .padding([.leading, .trailing], titleHorizontalPadding)
                    .padding([.top, .bottom], titleVerticalPadding)
            }
        }
        .frame(width: width, height: height, alignment: .center)
        .background(Color.white)
        .accentColor(ColorPalette.gtBlue.color)
        .cornerRadius(cornerRadius)
        .accessibilityIdentifier(accessibility?.id ?? "")
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(ColorPalette.gtBlue.color, lineWidth: 1)
        )
    }
}

struct GTWhiteButton_Previews: PreviewProvider {
    static var previews: some View {
        GTWhiteButton(title: "Test Button", width: 240, height: 50, action: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
