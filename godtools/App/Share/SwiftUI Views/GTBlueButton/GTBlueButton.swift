//
//  GTBlueButton.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

struct GTBlueButton: View {
        
    let title: String
    let font: Font
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    let highlightsTitleOnTap: Bool
    let accessibility: AccessibilityStrings.Button?
    let action: () -> Void
    
    init(title: String, font: Font? = nil, fontSize: CGFloat? = nil, width: CGFloat, height: CGFloat, cornerRadius: CGFloat = 6, highlightsTitleOnTap: Bool = true, accessibility: AccessibilityStrings.Button? = nil, action: @escaping () -> Void) {
        
        self.title = title
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.highlightsTitleOnTap = highlightsTitleOnTap
        self.accessibility = accessibility
        self.action = action
        
        if let font = font {
            self.font = font
        }
        else if let fontSize = fontSize {
            self.font = GTBlueButton.getDefaultFont(fontSize: fontSize)
        }
        else {
            self.font = GTBlueButton.getDefaultFont(fontSize: 12)
        }
    }
    
    private static func getDefaultFont(fontSize: CGFloat) -> Font {
        return FontLibrary.sfProTextRegular.font(size: fontSize)
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            Button(action: {
                action()
            }) {
                
                ZStack(alignment: .center) {
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(width: width, height: height)
                        .cornerRadius(cornerRadius)
                    
                    if highlightsTitleOnTap {
                        getButtonTitle()
                    }
                }
            }
            .accessibilityIdentifier(accessibility?.id ?? "")
            .frame(width: width, height: height, alignment: .center)
            .background(ColorPalette.gtBlue.color)
            .cornerRadius(cornerRadius)
            
            if !highlightsTitleOnTap {
                getButtonTitle()
            }
        }
    }
    
    @ViewBuilder private func getButtonTitle() -> some View {
        
        Text(title)
            .font(font)
            .foregroundColor(Color.white)
            .padding()
    }
}

struct GTBlueButton_Previews: PreviewProvider {
    static var previews: some View {
        GTBlueButton(title: "Test Button", width: 240, height: 50, cornerRadius: 6, action: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
